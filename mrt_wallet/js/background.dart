import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

import 'js_wallet/constant/constant.dart';

@JS("OnBackgroundListener_")
external set _OnContentListener(JSFunction? f);

@JS("OnBackgroundListener_")
external JSFunction get _OnContentListener;

class _Wallet extends WalletCore {
  @override
  bool get isJsWallet => true;
  @override
  void onChange() {}

  @override
  void onChangeStatus(WalletPageStatus status, {String? message}) {}

  @override
  bool onWeb3Request(Web3Request request) {
    throw UnimplementedError();
  }

  @override
  Future<void> initWallet(
      {bool useIsolate = false, String? initialPassword}) async {
    await PlatformInterface.instance.getConfig();
    await super.initWallet(useIsolate: useIsolate);
  }
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

    bool onMessage(
        JSWalletEvent message, MessageSender sender, JSFunction sendResponse) {
      final event = message.toEvent();
      if (event?.type != WalletEventTypes.popup) {
        return false;
      }
      extension.runtime.sendMessage_(message: messageToSend).then((e) {
        completer.complete(e);
        sendResponse.callAsFunction(sendResponse, null);
        return e;
      }).catchError((e) {
        completer.completeError(e);
        sendResponse.callAsFunction(sendResponse, null);
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

void main() async {
  final wallet = _Wallet();
  final lock = SynchronizedLock();
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
      final top = info.top! + 50;
      final left = info.width! - 175;
      await extension.windows.create_(
        url: extension.runtime.getURL("index.html"),
        type: JSWalletConstant.extentionType,
        width: JSWalletConstant.extentionWidth,
        height: JSWalletConstant.extentionHeight,
        top: top,
        focused: true,
        left: left,
      );
      final result = await sendPopupRuntimeMessage(JSWalletConstant.create);
      return result;
    });
  }

  Future<WalletEvent> tabInformation(ChromeTab tab, WalletEvent event) async {
    try {
      if (tab.id == null) {
        throw Web3RequestExceptionConst.invalidHost;
      }
      await wallet.initWallet();
      if (wallet.isSetup) {
        throw Web3RequestExceptionConst.walletNotInitialized;
      }
      APPImage image = APPImage.faviIcon(tab.url!);
      if (tab.favIconUrl != null) {
        final data = await wallet.crypto.generateUUID(dataHex: tab.favIconUrl);
        image = APPImage.network(tab.favIconUrl!, data);
      }

      final Web3ClientInfo? client = Web3ClientInfo.info(
          clientId: "${tab.id!}",
          url: tab.url!,
          faviIcon: image,
          name: tab.title);
      final authenticated = await wallet.getWeb3Authenticated(client!);
      return WalletEvent(
          clientId: "${tab.id!}",
          data: authenticated.result.toCbor().encode(),
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

  extension.runtime.onInstalled
      .addListener((OnInstalledDetails details) {}.toJS);
  extension.runtime.onMessage.addListener(
      (JSWalletEvent message, MessageSender sender, JSFunction sendResponse) {
    final event = message.toEvent();

    if (event == null) return false;
    switch (event.type) {
      case WalletEventTypes.openExtension:
        openPopup()
            .then(
                (e) => sendResponse.callAsFunction(sendResponse, e.toJsEvent()))
            .catchError((e) {
          return e;
        });
        return true;
      case WalletEventTypes.tabId:
        tabInformation(sender.tab!, event).then((e) {
          sendResponse.callAsFunction(sendResponse, e.toJsEvent());
        }).catchError((e) {
          return null;
        });

        return true;
      default:
        return false;
    }
  }.toJS);
  sendAlive();
}
