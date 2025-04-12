part of '../scripts.dart';

typedef PostWalletMessage = void Function(PageMessage);

abstract class WalletStandardPageController {
  final PageRequestController _requestController;
  WalletStandardPageController(this._requestController);
  abstract final JSClientType _client;

  JSPromise<T> waitForSuccessResponsePromise<T extends JSAny?>(
      {required String method,
      PageRequestType provider = PageRequestType.walletStandard,
      JSArray<JSAny>? params}) {
    return _requestController.waitForSuccessResponsePromise<T>(
        method: method, client: _client, params: params, provider: provider);
  }

  Future<T> waitForSuccessResponse<T extends JSAny?>(
      {required String method,
      PageRequestType provider = PageRequestType.walletStandard,
      JSArray<JSAny>? params}) async {
    return _requestController.waitForSuccessResponse<T>(
        method: method, client: _client, params: params, provider: provider);
  }

  JSPromise _disconnectChain() {
    return _requestController.waitForSuccessResponsePromise<JSAny?>(
        method: 'disconnect', client: _client);
  }

  void _emitEvent(PageMessageEvent message) {
    if (!message.eventType.needEmit) return;
    final toWalletRequest = PageMessage.event(data: message, client: _client);
    _requestController.postMessage(toWalletRequest);
  }

  void _initNetworkFeatures(JSWalletStandardFeature feature);
  final Map<JSEventType, List<JSFunction>> _listeners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
    JSEventType.change: []
  };

  void _onEvents(JSString type, JSFunction listener) {
    final eventType = JSEventType.fromName(type.toDart);
    if (eventType != null) {
      _listeners[eventType]!.add(listener);
      _emitEvent(PageMessageEvent.build(event: eventType));
    }
  }

  void _emit(List<JSFunction> listeners, JSAny? message) {
    final clone = [...listeners];
    for (final i in clone) {
      i.callAsFunction(i, message);
    }
  }

  void _eventListeners(JSEventType type, JSAny? message) {
    if (!_listeners.containsKey(type)) return;
    _emit(_listeners[type]!, message);
  }

  void onWalletEvent(WalletMessageEvent message) {
    final data = message.data as JSWalletNetworkEvent;
    final events = data.eventTypes;
    for (final event in events) {
      switch (event) {
        case JSNetworkEventType.change:
          _eventListeners(JSEventType.change, data.change);
          break;
        default:
      }
    }
  }
}

class PageRequestController {
  final POSTPAGEMESSAGE postMessage;
  PageRequestController(this.postMessage);

  final Map<String, PageRequestCompleter> _waitingRequest = {};
  void _completeRequest(WalletMessage walletResponse) {
    _waitingRequest[walletResponse.requestId]
        ?.completeMessage(walletResponse.data as WalletMessageResponse);
  }

  Future<WalletMessageResponse> _getWalleResponse(
      {required PageMessageRequest message, JSClientType? client}) async {
    final request = PageRequestCompleter.nextRequest();
    try {
      final toWalletRequest = PageMessage.request(
          data: message, requestId: request.id, client: client);
      postMessage(toWalletRequest);
      _waitingRequest[request.id] ??= request;
      return await request.wait;
    } finally {
      _waitingRequest.remove(request.id);
    }
  }

  JSPromise<T> waitForSuccessResponsePromise<T extends JSAny?>(
      {required String method,
      PageRequestType provider = PageRequestType.walletStandard,
      JSArray<JSAny>? params,
      JSClientType? client}) {
    return waitForSuccessResponse<T>(
            method: method, client: client, params: params, provider: provider)
        .toPromise;
  }

  Future<T> waitForSuccessResponse<T extends JSAny?>({
    required String method,
    PageRequestType provider = PageRequestType.walletStandard,
    JSArray<JSAny>? params,
    JSClientType? client,
  }) async {
    final message = PageMessageRequest.create(
        method: method, params: params, provider: provider);
    final response = await _getWalleResponse(message: message, client: client);
    switch (response.statusType) {
      case JSWalletResponseType.success:
        return response.data as T;
      case JSWalletResponseType.failed:
        throw JSWalletError.fromJson(message: response.asMap());
    }
  }
}
