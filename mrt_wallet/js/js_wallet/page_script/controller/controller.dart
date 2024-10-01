part of '../scripts.dart';

class JSPageController {
  JSPageController._();
  factory JSPageController.setup(String clientId) {
    final client = JSPageController._();
    PageNetworkController._walletId = JsUtils.toWalletId(clientId);
    jsWindow.addEventListener(
        JsUtils.toEthereumClientId(clientId), client._onWalletEvent.toJS);
    return client;
  }
  final EthereumPageController ethereumPageController =
      EthereumPageController();
  final TronPageController tronPageController = TronPageController();
  final SolanaPageController solanaPageController = SolanaPageController();
  final TonPageController tonPageController = TonPageController();
  final StellarPageController stellarPageController = StellarPageController();

  void _onWalletEvent(CustomEvent response) {
    try {
      final WalletMessage walletResponse = response.detail as WalletMessage;

      if (walletResponse.data.messageType == JSWalletMessageType.response) {
        PageNetworkController._compeleteRequest(
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
