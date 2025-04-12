import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'js_wallet/constant/constant.dart';

class _JSBackgroundHandler {
  final lock = SynchronizedLock();
  _JSBackgroundHandler._();
  static Future<_JSBackgroundHandler> init() async {
    await AppNativeMethods.platform.getConfig();
    return _JSBackgroundHandler._();
  }

  Future<String?> _read({required String key}) async {
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<Map<String, String>> _readAll({String? prefix}) async {
    return await AppNativeMethods.platform.readAllSecure(prefix: prefix);
  }

  Future<void> _write({required String key, required String data}) async {
    await AppNativeMethods.platform.writeSecure(key, data);
  }

  Future<List<Web3ChainNetworkData>> _readNetworks(HDWallet wallet) async {
    final List<Web3ChainNetworkData> web3Chains = [];
    final keys = await _readAll(prefix: wallet.networkKey);
    final data = keys.keys
        .where((e) => e.startsWith(wallet.networkKey))
        .map((e) => (e, keys[e]!))
        .toList();
    final keyBytes = data.map((e) => BytesUtils.fromHexString(e.$2)).toList();
    for (final i in keyBytes) {
      try {
        final obj = CborObject.fromCbor(i);
        final CborListValue values = CborSerializable.cborTagValue(
            object: obj, tags: CborTagsConst.iAccount);
        WalletNetwork? network = MethodUtils.nullOnException(() {
          return WalletNetwork.fromCborBytesOrObject(obj: values.getCborTag(6));
        });
        network = MethodUtils.nullOnException(() => ChainConst.updateNetwork(
            networkId: values.elementAs(0), network: network));
        if (network == null || !network.supportWeb3) continue;
        final ProviderIdentifier? serviceIdentifier =
            MethodUtils.nullOnException(() {
          final CborTagValue? identifier = values.elementAs(10);
          if (identifier == null) return null;
          return ProviderIdentifier.deserialize(cbor: identifier);
        });
        final Web3ChainNetworkData n = switch (network.type) {
          NetworkType.ethereum => Web3ChainNetworkData<WalletEthereumNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.tron => Web3ChainNetworkData<WalletTronNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.solana => Web3ChainNetworkData<WalletSolanaNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.stellar => Web3ChainNetworkData<WalletStellarNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.ton => Web3ChainNetworkData<WalletTonNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.substrate => Web3ChainNetworkData<WalletSubstrateNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.aptos => Web3ChainNetworkData<WalletAptosNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.sui => Web3ChainNetworkData<WalletSuiNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.cosmos => Web3ChainNetworkData<WalletCosmosNetwork>(
              network: network.toNetwork(),
              serviceIdentifier: serviceIdentifier),
          NetworkType.bitcoinAndForked ||
          NetworkType.bitcoinCash =>
            Web3ChainNetworkData<WalletBitcoinNetwork>(
                network: network.toNetwork(),
                serviceIdentifier: serviceIdentifier),
          _ => throw UnimplementedError()
        };
        web3Chains.add(n);
      } catch (_) {}
    }
    return web3Chains;
  }

  Future<HDWallet?> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return null;
    }
    return HDWallets.fromCborBytesOrObject(hex: wallet).getInitializeWallet();
  }

  Future<Web3APPAuthentication> getPermission(
      {required Web3ClientInfo info, required HDWallet wallet}) async {
    final applicationKey =
        BytesUtils.toHexString(MD4.hash(info.applicationId.codeUnits));
    final permission = await _read(key: wallet.toPermissionKey(applicationKey));
    Web3APPAuthentication? toPermission = MethodUtils.nullOnException(() {
      return Web3APPAuthentication.deserialize(hex: permission);
    });
    if (toPermission == null) {
      final token = QuickCrypto.generateRandom();
      final permission = Web3APPAuthentication.create(
          name: info.name,
          applicationKey: applicationKey,
          applicationId: info.applicationId,
          icon: info.image,
          token: token);
      await _write(
          key: wallet.toPermissionKey(permission.applicationKey),
          data: permission.toCbor().toCborHex());
      toPermission = permission;
    }
    return toPermission;
  }

  Future<Web3EncryptedMessage> toEncryptedMessage(
      {required List<int> key, required List<int> message}) async {
    final chacha = ChaCha20Poly1305(key);
    final nonce = QuickCrypto.generateRandom(12);
    final encryptedKey = chacha.encrypt(nonce, message);
    return Web3EncryptedMessage(message: encryptedKey, nonce: nonce);
  }

  Future<Web3EncryptedMessage> _getOrCreateAppAuthenticated(
      {required Web3ClientInfo info, required HDWallet wallet}) async {
    Web3APPAuthentication? toPermission =
        await getPermission(info: info, wallet: wallet);
    final sha256 = SHA256.hash(StringUtils.encode(info.clientId));
    final networks = await _readNetworks(wallet);
    final auth = toPermission.createAuth(networks);
    final message =
        Web3ChainMessage(authenticated: auth, type: Web3MessageTypes.chains);
    return toEncryptedMessage(message: message.toCbor().encode(), key: sha256);
  }

  Future<void> send(JSWalletEvent? event, int? tabId) async {
    if (event == null || tabId == null) return;
    await extension.tabs
        .sendMessage_(tabId: tabId, message: event)
        .catchError((e) {
      return null;
    });
  }

  Future<void> sendAlive() async {
    final tabs = await extension.tabs.query_();
    for (final i in tabs) {
      send(JSWalletConstant.ping.toJsEvent(), i.id);
    }
  }

  Future<WalletEvent> sendPopupRuntimeMessage(WalletEvent messageToSend) async {
    bool hasListener = false;
    try {
      final Completer<WalletEvent> completer = Completer();

      bool onMessage(JSWalletEvent message, MessageSender sender,
          JSFunction sendResponse) {
        final event = message.toEvent();
        if (event?.type != WalletEventTypes.popup) {
          return false;
        }
        extension.runtime.sendMessage_(message: messageToSend).then((e) {
          completer.complete(e);
          sendResponse.callAsFunction(null, null);
          return e;
        }).catchError((e) {
          completer.completeError(e);
          sendResponse.callAsFunction(null, null);
          return null;
        });
        return true;
      }

      extension.runtime.sendMessage_(message: messageToSend).then((e) {
        completer.complete(e);
      }).catchError((e) {
        _OnContentListener = onMessage.toJS;
        extension.runtime.onMessage.addListener(_OnContentListener);
        hasListener = true;
        return null;
      });
      return await completer.future;
    } finally {
      if (hasListener) {
        extension.runtime.onMessage.removeListener(_OnContentListener);
      }
    }
  }

  Future<HDWallet> getWallet() async {
    final wallet = await _readWallet();
    if (wallet == null) throw Web3RequestExceptionConst.walletNotInitialized;
    return wallet;
  }

  Web3ClientInfo buildClient(ChromeTab tab) {
    APPImage? image = APPImage.network(tab.favIconUrl);
    image ??= APPImage.faviIcon(tab.url!);
    final Web3ClientInfo? client = Web3ClientInfo.info(
        clientId: tab.id?.toString(),
        url: tab.url,
        faviIcon: image,
        name: tab.title);
    if (client == null) {
      throw Web3RequestExceptionConst.invalidHost;
    }
    return client;
  }

  Future<WalletEvent> openPopup() async {
    return await lock.synchronized(() async {
      final WalletEvent? windowIdResponse = await extension.runtime
          .sendMessage_(message: JSWalletConstant.windowIdEvent)
          .then((e) => e)
          .catchError((e) => null);
      if (windowIdResponse != null) {
        final int windowId = IntUtils.fromBytes(windowIdResponse.data);
        if (windowId > 0) {
          await extension.windows.update_(windowId, focused: true);
        }
        return JSWalletConstant.popEvent;
      }
      final info = await extension.windows.getCurrent_(populate: true);
      final newLeft = IntUtils.max(0, info.left! + 100);
      final newTop = IntUtils.max(0, info.top! + 100);
      final newWidth = IntUtils.min(info.width!, 400);
      final newHeight = IntUtils.min(info.height!, 600);
      await extension.windows.create_(
          url: extension.runtime.getURL("index.html"),
          type: JSWalletConstant.extentionType,
          width: newWidth,
          height: newHeight,
          top: newTop,
          focused: true,
          left: newLeft);
      final result = await sendPopupRuntimeMessage(JSWalletConstant.create);
      return result;
    });
  }

  Future<WalletEvent> onBackgroudMessage(
      WalletEvent event, ChromeTab tab) async {
    try {
      final wallet = await getWallet();
      final Web3ClientInfo client = buildClient(tab);
      final type = NetworkType.fromTag(event.data);
      final appAuthenticated =
          await getPermission(info: client, wallet: wallet);
      appAuthenticated.disconnectChain(type);
      await _write(
          key: wallet.toPermissionKey(appAuthenticated.applicationKey),
          data: appAuthenticated.toCbor().toCborHex());
      final networks = await _readNetworks(wallet);
      final auth = appAuthenticated.createAuth(networks);
      final response = Web3WalletResponseMessage(
          result: true, network: type, authenticated: auth);
      final message = await toEncryptedMessage(
          key: appAuthenticated.token, message: response.toCbor().encode());
      return WalletEvent(
          clientId: "${tab.id!}",
          data: message.toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.message);
    } on Web3RequestException catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: e.toResponseMessage().toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception);
    } catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: Web3RequestExceptionConst.internalError
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception);
    }
  }

  Future<WalletEvent> tabInformation(ChromeTab tab, WalletEvent event) async {
    try {
      final wallet = await getWallet();
      final Web3ClientInfo client = buildClient(tab);
      final authenticated =
          await _getOrCreateAppAuthenticated(info: client, wallet: wallet);
      return WalletEvent(
          clientId: "${tab.id!}",
          data: authenticated.toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.activation);
    } on Web3RequestException catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: e.toResponseMessage().toCbor().encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception);
    } catch (e) {
      return WalletEvent(
          clientId: "${tab.id ?? -1}",
          data: Web3RequestExceptionConst.internalError
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.requestId,
          type: WalletEventTypes.exception);
    }
  }
}

@JS("OnBackgroundListener_")
external set _OnContentListener(JSFunction? f);

@JS("OnBackgroundListener_")
external JSFunction get _OnContentListener;

void main() async {
  final handler = await _JSBackgroundHandler.init();
  extension.runtime.onInstalled
      .addListener((OnInstalledDetails details) {}.toJS);
  extension.runtime.onMessage.addListener(
      (JSWalletEvent message, MessageSender sender, JSFunction sendResponse) {
    final event = message.toEvent();
    if (event == null) return false;
    switch (event.type) {
      case WalletEventTypes.background:
        handler.onBackgroudMessage(event, sender.tab!).then(
            (e) => sendResponse.callAsFunction(sendResponse, e.toJsEvent()));
        return true;
      case WalletEventTypes.openExtension:
        handler.openPopup().then(
            (e) => sendResponse.callAsFunction(sendResponse, e.toJsEvent()));
        return true;

      case WalletEventTypes.tabId:
        handler.tabInformation(sender.tab!, event).then((e) {
          sendResponse.callAsFunction(sendResponse, e.toJsEvent());
        });
        return true;
      default:
        return false;
    }
  }.toJS);
  handler.sendAlive();
}
