part of '../scripts.dart';

class TonPageController extends PageNetworkController {
  TonPageController();
  ProxyMethodHandler<TonWalletAdapter>? _ton;
  ProxyMethodHandler<TonWalletAdapter> _createAdapter() {
    final adapter = TonWalletAdapter(JSObject());
    adapter.enable = _requestAccount.toJS;
    adapter.on = _addListener.toJS;
    adapter.on = _addListener.toJS;

    adapter.removeListener = _removeListener.toJS;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _onWalletRequest.toJS;
    adapter.cancelAllListener = _cancelAllListeners.toJS;
    return ProxyMethodHandler<TonWalletAdapter>(adapter);
  }

  void _init() {
    _ton ??= _createAdapter();
    final proxy = Proxy(_ton!.object, createJSInteropWrapper(_ton!));
    ton = proxy;
  }

  JSPromise<JSAny?> _requestAccount() {
    final params = Web3JSRequestParams(method: "ton_requestAccounts");
    return _onWalletRequest(params);
  }

  void _disable(String? message) {
    ton = null;
    jsConsole.error(message);
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final chainChange = TonChainChanged.fromJson(message.asMap());
        eventData = chainChange.workChain.toJS;
        break;
      case JSEventType.chainChanged:
        final chainChange = TonChainChanged.fromJson(message.asMap());
        eventData = chainChange.toJS;
        break;
      case JSEventType.accountsChanged:
        final chainChange = TonAccountsChanged.fromJson(message.asMap());
        eventData = chainChange.accountJS;
        _ton?.object.selectedAddress = chainChange.defaultAddress?.toJS;
        break;
      case JSEventType.disconnect:
        _ton?.object.selectedAddress = null;
        break;
      case JSEventType.disable:
        _disable(message.asString());
        return;
      case JSEventType.active:
        _init();
        return;
      default:
        return;
    }
    _eventListeners(message.eventType, jsObject: eventData);
  }

  void _eventListeners(JSEventType type, {JSAny? jsObject}) {
    if (!_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _addListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null || !_listeners.containsKey(event)) return;
    _listeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _removeListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _listeners[event]?.remove(listener);
  }

  void _cancelAllListeners() {
    for (final i in _listeners.keys.toList()) {
      _listeners[i]!.clear();
    }
  }

  @override
  JSClientType get _client => JSClientType.ton;
}
