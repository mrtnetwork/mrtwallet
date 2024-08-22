part of '../scripts.dart';

abstract class JSBasePageController {
  final String clientId;
  late final String _id = JsUtils.toEthereumClientId(clientId);
  late final String _walletId = JsUtils.toWalletId(clientId);
  JSBasePageController._(this.clientId);

  final Map<String, PageRequestCompeleter> _waitingRequest = {};

  void _postWalletEvent(ClientMessage params) {
    final event =
        CustomEvent.create(type: _walletId, data: params.toCbor().encode());
    jsWindow.dispatchEvent(event);
  }

  Future<JSAny?> _onRequest(PageRequestCompeleter id) async {
    try {
      _waitingRequest[id.id] ??= id;
      return await id.completer.future;
    } finally {
      _waitingRequest.remove(id.id);
    }
  }

  Future<JSAny?> _getResult(Web3JSRequestParams params) async {
    final id = UUID.generateUUIDv4();
    final toWalletRequest = params.toWalletRequest(id);
    _postWalletEvent(toWalletRequest!);
    final PageRequestCompeleter request = PageRequestCompeleter(id);
    final result = await _onRequest(request);
    return result;
  }
}
