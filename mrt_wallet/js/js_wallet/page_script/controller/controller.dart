part of '../scripts.dart';

typedef POSTPAGEMESSAGE = void Function(PageMessage message);

abstract class JSBasePageController {
  void postMessage(PageMessage message) {}
  late final EthereumPageController ethereumPageController =
      EthereumPageController(postMessage);
  late final TronPageController tronPageController =
      TronPageController(postMessage);
  late final SolanaPageController solanaPageController =
      SolanaPageController(postMessage);
  late final TonPageController tonPageController =
      TonPageController(postMessage);
  late final StellarPageController stellarPageController =
      StellarPageController(postMessage);
  void handleWalletMessage(WalletMessage walletResponse) {
    try {
      if (walletResponse.data.messageType == JSWalletMessageType.response) {
        PageNetworkController._completeRequest(
            requestId: walletResponse.requestId,
            walletResponse: walletResponse.data as WalletMessageResponse);
        return;
      }
      final event = walletResponse.data as WalletMessageEvent;
      switch (walletResponse.clientType) {
        case JSClientType.ethereum:
          ethereumPageController.onEvent(event);
          break;
        case JSClientType.tron:
          tronPageController.onEvent(event);
          break;
        case JSClientType.solana:
          solanaPageController.onEvent(event);
          break;
        case JSClientType.ton:
          tonPageController.onEvent(event);
          break;
        case JSClientType.stellar:
          stellarPageController.onEvent(event);
          break;
        default:
          break;
      }
    } catch (e) {
      rethrow;
    }
  }
}

class JSPageController extends JSBasePageController {
  JSPageController._();
  @override
  void postMessage(PageMessage message) {
    final event = CustomEvent.create(
        type: PageNetworkController._walletId, detail: message);
    jsWindow.dispatchEvent(event);
  }

  factory JSPageController.setup(String clientId) {
    final client = JSPageController._();
    PageNetworkController._walletId = JsUtils.toWalletId(clientId);
    jsWindow.addEventListener(
        JsUtils.toEthereumClientId(clientId), client._onWalletEvent.toJS);
    return client;
  }

  void _onWalletEvent(CustomEvent response) {
    final WalletMessage walletResponse = response.detail as WalletMessage;
    handleWalletMessage(walletResponse);
  }
}

class JSWithWorkerPageController extends JSBasePageController {
  final Worker _worker;
  JSWithWorkerPageController._(this._worker);
  @override
  void postMessage(PageMessage message) {
    _worker
        .postMessage(JSWorkerEvent(data: message, type: JSWorkerType.client));
  }

  factory JSWithWorkerPageController.setup(
      {required String clientId, required Worker worker}) {
    final client = JSWithWorkerPageController._(worker);
    PageNetworkController._walletId = JsUtils.toWalletId(clientId);
    return client;
  }

  void onWalletEvent(WalletMessage response) {
    handleWalletMessage(response);
  }
}
