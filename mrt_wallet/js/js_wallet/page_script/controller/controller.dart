part of '../scripts.dart';

class JSPageController {
  JSPageController._(this.clientId);
  late final EthereumPageController ethereumPageController =
      EthereumPageController(getWalletMessage: _getResult);
  late final TronPageController tronPageController =
      TronPageController(getWalletMessage: _getResult);
  final String clientId;
  late final String _id = JsUtils.toEthereumClientId(clientId);
  late final String _walletId = JsUtils.toWalletId(clientId);

  final Map<String, PageRequestCompeleter> _waitingRequest = {};

  void _postWalletEvent(JSPageRequest params) {
    final event =
        CustomEvent.create(type: _walletId, data: params.toCbor().encode());
    jsWindow.dispatchEvent(event);
  }

  Future<JSAny?> _getResult(PageMessage message) async {
    final request = PageRequestCompeleter.nextRequest();
    try {
      final toWalletRequest = JSPageRequest(message: message, id: request.id);
      _postWalletEvent(toWalletRequest);
      _waitingRequest[request.id] ??= request;
      final result = await request.wait;
      return result;
    } finally {
      _waitingRequest.remove(request.id);
    }
  }

  factory JSPageController.setup(String clientId) {
    final client = JSPageController._(clientId);
    client._init();
    return client;
  }
  void _init() {
    jsWindow.addEventListener(_id, _onWalletEvent.toJS);
  }

  void _onWalletEvent(CustomEvent response) {
    final walletResponse =
        JSWalletMessage.deserialize(bytes: response.detailBytes());
    if (walletResponse.type == JSWalletMessageType.response) {
      _waitingRequest[walletResponse.requestId]
          ?.completeMessage(walletResponse.cast());
      return;
    }
    switch (walletResponse.client) {
      case JSClientType.ethereum:
        ethereumPageController.onEvent(walletResponse.cast());
        break;
      case JSClientType.tron:
        tronPageController.onEvent(walletResponse.cast());
        break;
      default:
        break;
    }
  }
}
