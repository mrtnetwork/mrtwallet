import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/controller/models/key.dart';
import 'package:mrt_wallet/future/wallet/controller/models/login_history.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/requests/chacha.dart';

class ExtentionSessionStorageConst {
  static const String key = "extention_setting";
  static const String history = "extention_history";
  static const String expireKey = "extention_expire";
  static const List<int> keyTag = [23, 123, 21, 10];
  static const List<int> historyTag = [123, 21, 10, 21];
}

mixin ExtentionWalletHandler on Web3RequestControllerImpl {
  bool _fromAction = true;
  final sessionStorage = extension.storage.session;
  StreamSubscription<int>? _onWalletExpireTime;
  @override
  Future<Web3ClientInfo?> currentApllicationId() async {
    final tabs = await extension.tabs.query_(
        active: true,
        lastFocusedWindow: _fromAction ? true : false,
        currentWindow: _fromAction);
    if (tabs.length != 1) return null;
    final tab = tabs[0];
    final client = createClientInfos(
        clientId: tab.id?.toString(),
        url: tab.url,
        title: tab.title,
        faviIcon: tab.favIconUrl);
    return client;
  }

  void _onTick(int _) {
    final t = walletCore.reminingWalletTime;
    if (t == null) return;
    final expire = DateTime.now().add(Duration(seconds: t));
    _saveExpireTime(expire);
  }

  Future<void> _saveExpireTime(DateTime expire) async {
    await sessionStorage.setStorage_(ExtentionSessionStorageConst.expireKey,
        expire.secondsSinceEpoch.toString());
  }

  void _disposeExpireChecker() {
    _onWalletExpireTime?.cancel();
    _onWalletExpireTime = null;
  }

  void _buildTimerChecker() {
    _disposeExpireChecker();
    _onWalletExpireTime =
        Stream<int>.periodic(const Duration(seconds: 10), (e) => e)
            .listen(_onTick);
  }

  Future<void> clearLoginHistory() async {
    await sessionStorage.removeMultiple_([
      ExtentionSessionStorageConst.history,
      ExtentionSessionStorageConst.key,
      ExtentionSessionStorageConst.expireKey
    ]);
    _disposeExpireChecker();
  }

  Future<void> saveLoginHistory(String key) async {
    final int? reminig = walletCore.reminingWalletTime;
    if (reminig == null) return;
    final expire = DateTime.now().add(Duration(seconds: reminig));
    final walletKey = ExtentionWalletKey(key);
    final encryptionKey = ExtentionKey.generate();
    final encrypt = await crypto.cryptoRequest(CryptoRequestEncryptChacha(
        message: walletKey.toCbor().encode(),
        key: encryptionKey.keyBytes,
        nonce: encryptionKey.nonceBytes));
    await sessionStorage.setMultipleStorage_({
      ExtentionSessionStorageConst.key: encryptionKey.toCbor().toCborHex(),
      ExtentionSessionStorageConst.history: encrypt.encryptedHex,
      ExtentionSessionStorageConst.expireKey:
          expire.secondsSinceEpoch.toString(),
    });
    _buildTimerChecker();
  }

  Future<String?> getLoginHistory() async {
    final history = await MethodUtils.call(() async {
      final keys = await sessionStorage.getMultipleStorage_([
        ExtentionSessionStorageConst.key,
        ExtentionSessionStorageConst.history,
        ExtentionSessionStorageConst.expireKey
      ]);
      final expireTime = QuickDateTimeFormater.fromSecondsSinceEpoch(
          int.parse(keys[ExtentionSessionStorageConst.expireKey]!));
      final ExtentionKey key =
          ExtentionKey.deserialize(hex: keys[ExtentionSessionStorageConst.key]);
      final decrypt = await crypto.cryptoRequest(
          CryptoRequestDecryptChacha.fromHex(
              message: keys[ExtentionSessionStorageConst.history]!,
              key: key.key,
              nonce: key.nonce));
      final walletKey =
          ExtentionWalletKey.deserialize(bytes: decrypt.decrypted);
      if (expireTime.isAfterNow) {
        return walletKey.key;
      }
      await clearLoginHistory();
      return null;
    });
    if (history.hasResult) {
      return history.result;
    }
    return null;
  }

  bool _onRuntimeMessage(
      JSWalletEvent? message, MessageSender sender, JSFunction sendResponse) {
    final event = message?.toEvent();
    switch (event?.type) {
      case WalletEventTypes.popup:
        sendResponse.callAsFunction(sendResponse, message);
        if (event?.requestId == "1") {
          _fromAction = false;
        }
        return true;
      case WalletEventTypes.windowId:
        extension.windows
            .getCurrent_(populate: false, windowTypes: ["popup"]).then((e) {
          sendResponse.callAsFunction(
              sendResponse,
              WalletEvent(
                      clientId: event!.clientId,
                      data: IntUtils.toBytes(e.id!,
                          length: IntUtils.bitlengthInBytes(e.id!)),
                      requestId: event.requestId,
                      type: WalletEventTypes.windowId)
                  .toJsEvent());
        }).catchError((e) {
          sendResponse.callAsFunction(
              sendResponse,
              WalletEvent(
                      clientId: event!.clientId,
                      data: const [],
                      requestId: event.requestId,
                      type: WalletEventTypes.exception)
                  .toJsEvent());
          return null;
        });
        return true;
      default:
        break;
    }
    return false;
  }

  void _onMessage(JSWalletEvent message, RuntimePort port) async {
    try {
      final event = message.toEvent();
      if (event == null) return;
      if (event.type == WalletEventTypes.ping) {
        port.postMessage(message);
        return;
      }
      final tab = await extension.tabs.get_(int.parse(event.clientId));

      final Web3ClientInfo? client = await createClientInfos(
          clientId: tab.id?.toString(),
          url: tab.url,
          faviIcon: tab.favIconUrl,
          title: tab.title);
      if (client == null || event.clientId != "${tab.id}") {
        port.postMessage(toResponseEvent(
                id: "${tab.id}",
                type: WalletEventTypes.exception,
                data: Web3RequestExceptionConst.invalidHost
                    .toResponseMessage()
                    .toCbor()
                    .encode(),
                requestId: event.requestId)
            .toJsEvent());

        return;
      }
      final request =
          Web3RequestApplicationInformation(info: client, request: event);
      onWalletEvent(request);
      void onDisconnect(RuntimePort port) {
        request.completeError();
      }

      port.onDisconnect.addListener(onDisconnect.toJS);
      final responseEvent = await request.onCompleteRequest;
      port.postMessage(responseEvent.toJsEvent());
      request.completeSuccess();
      port.onDisconnect.removeListener(onDisconnect.toJS);
      // ignore: empty_catches
    } catch (e) {}
  }

  void _onDisconnect(RuntimePort port) {}

  void _onConnet(RuntimePort port) {
    port.onMessage.addListener(_onMessage.toJS);
    port.onDisconnect.addListener(_onDisconnect.toJS);
  }

  void _onActivateChain(ActiveInfo info) {
    final tabInfo =
        extension.tabs.query_(windowId: info.windowId, active: true);
    tabInfo.then(_updateTabs);
  }

  void _updateTabs(List<ChromeTab> tabs) async {
    for (final i in tabs) {
      final client = await createClientInfos(
          clientId: i.id?.toString(),
          url: i.url,
          title: i.title,
          faviIcon: i.favIconUrl);
      if (client == null) continue;
      final permission = await walletCore.getWeb3Permission(client);
      if (permission.hasResult) {
        final event = toResponseEvent(
            id: "${i.id}",
            type: WalletEventTypes.message,
            data: permission.result.toCbor().encode());
        sendToClient(event);
      }
    }
  }

  static final popEvent = WalletEvent(
      clientId: extension.runtime.id,
      data: const [],
      requestId: "",
      type: WalletEventTypes.popup);

  void initExtention() {
    extension.runtime.onMessage.addListener(_onRuntimeMessage.toJS);
    extension.runtime.onConnect.addListener(_onConnet.toJS);
    extension.tabs.onActivated.addListener(_onActivateChain.toJS);
    extension.runtime.sendMessage_(message: popEvent);
  }

  @override
  Future<void> updatePermission(Web3APPAuthentication updatePermission) async {
    final update =
        (await walletCore.updateWeb3Application(updatePermission)).result;
    final tabs =
        await extension.tabs.query_(host: updatePermission.applicationId);
    if (tabs.isNotEmpty) {
      for (final i in tabs) {
        if (i.id == null) continue;
        final event = toResponseEvent(
            id: "${i.id}",
            type: WalletEventTypes.message,
            data: update.toCbor().encode());
        sendToClient(event);
      }
    }
  }

  @override
  Future<void> sendToClient(WalletEvent event) async {
    await extension.tabs
        .sendMessage_(
            tabId: int.parse(event.clientId), message: event.toJsEvent())
        .timeout(APPConst.tenSecoundDuration, onTimeout: () => null)
        .catchError((e) {
      return null;
    });
  }
}
