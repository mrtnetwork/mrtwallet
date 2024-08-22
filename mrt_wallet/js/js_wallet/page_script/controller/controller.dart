part of '../scripts.dart';

class JSPageController extends JSBasePageController
    with EthereumPageController, TronJScontroller {
  JSPageController._(String clientId) : super._(clientId);
  factory JSPageController.setup(String clientId) {
    final client = JSPageController._(clientId);
    client._listenOnWallet();
    client._initEthereum();
    client._initTron();
    return client;
  }
  void _listenOnWallet() {
    jsWindow.addEventListener(_id, _onWalletEvent.toJS);
  }

  void _onWalletEvent(CustomEvent response) {
    final walletResponse =
        JSWalletMessage.deserialize(bytes: response.detailBytes());

    switch (walletResponse.client) {
      case JSClientType.ethereum:
        _onEthereumWalletEvent(walletResponse);
        break;
      default:
        throw UnimplementedError("Wrong response in page.");
    }
  }
}
