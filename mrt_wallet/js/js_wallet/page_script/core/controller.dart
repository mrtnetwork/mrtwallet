part of '../scripts.dart';

typedef PostWalletMessage = void Function(PageMessage);

abstract class PageNetworkController {
  final POSTPAGEMESSAGE postMessage;
  PageNetworkController(this.postMessage);
  int _id = 0;
  abstract final JSClientType _client;

  // static late final String _walletId;
  static final Map<String, PageRequestCompleter> _waitingRequest = {};
  final Map<JSEventType, List<JSFunction>> _listeners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
    JSEventType.connect: [],
    JSEventType.message: [],
    JSEventType.disconnect: [],
    JSEventType.change: []
  };
  static void _completeRequest(
      {required WalletMessageResponse walletResponse,
      required String requestId}) {
    _waitingRequest[requestId]?.completeMessage(walletResponse);
  }

  JSPromise<JSAny?> _postWalletRequest(Web3JSRequestParams params) {
    final message = PageMessageRequest.create(
        method: params.method,
        params: params.params,
        id: params.id ?? (_id++).toString());
    final promise = _postWalletRequestMessage(message).toPromise;
    return promise;
  }

  JSPromise<JSAny?> _postNetworkRequest(Web3JSRequestParams params) {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = _postNetworkRequestMessage(message).toPromise;
    return promise;
  }

  JSPromise<JSAny?> _disconnectChain() {
    final message =
        PageMessageRequest.create(method: 'disconnect', id: (_id++).toString());
    final promise = _postWalletRequestMessage(message).toPromise;
    return promise;
  }

  Future<WalletMessageResponse> _getWalleResponse(
      PageMessageRequest message) async {
    final request = PageRequestCompleter.nextRequest();
    try {
      final toWalletRequest =
          PageMessage.request(data: message, id: request.id, client: _client);
      postMessage(toWalletRequest);
      _waitingRequest[request.id] ??= request;
      return await request.wait;
    } finally {
      _waitingRequest.remove(request.id);
    }
  }

  void _emitEvent(PageMessageEvent message) {
    if (!message.eventType.needEmit) return;
    final toWalletRequest =
        PageMessage.event(data: message, id: "", client: _client);
    postMessage(toWalletRequest);
  }

  Future<T> _postNetworkRequestMessage<T extends JSAny?>(
      PageMessageRequest message) async {
    final response = await _getWalleResponse(message);
    switch (response.statusType) {
      case JSWalletResponseType.success:
        return response.data as T;
      case JSWalletResponseType.failed:
        throw JSWalletError.fromJson(message: response.asMap());
    }
  }

  Future<WalletResponse> _postWalletRequestMessage(
      PageMessageRequest message) async {
    final response = await _getWalleResponse(message);
    switch (response.statusType) {
      case JSWalletResponseType.success:
        return WalletResponseSuccess(id: message.id, result: response.data);
      case JSWalletResponseType.failed:
        return WalletResponseError(
            id: message.id,
            error: JSWalletError.fromJson(message: response.asMap()));
    }
  }
}
