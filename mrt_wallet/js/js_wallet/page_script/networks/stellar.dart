part of '../scripts.dart';

class StellarPageController extends PageNetworkController {
  StellarPageController();
  ProxyMethodHandler<StellarWalletAdapter>? _stellar;
  ProxyMethodHandler<StellarWalletAdapter> _createAdapter() {
    final adapter = StellarWalletAdapter(JSObject());
    adapter.enable = _requestAccount.toJS;
    adapter.on = _addListener.toJS;
    adapter.on = _addListener.toJS;

    adapter.removeListener = _removeListener.toJS;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _onWalletRequest.toJS;
    adapter.cancelAllListener = _cancelAllListeners.toJS;
    return ProxyMethodHandler<StellarWalletAdapter>(adapter);
  }

  void _init() {
    _stellar ??= _createAdapter();
    final proxy = Proxy(_stellar!.object, createJSInteropWrapper(_stellar!));
    stellar = proxy;
  }

  JSPromise<JSAny?> _requestAccount() {
    final params = Web3JSRequestParams(method: "stellar_requestAccounts");
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
        final chainChange =
            StellarProviderConnectInfo.fromJson(message.asMap());
        eventData = chainChange.passphrase.toJS;
        break;
      case JSEventType.chainChanged:
        final chainChange =
            StellarProviderConnectInfo.fromJson(message.asMap());
        eventData = chainChange.toJS;
        break;
      case JSEventType.accountsChanged:
        final chainChange = StellarAccountsChanged.fromJson(message.asMap());
        eventData = chainChange.accountJS;
        _stellar?.object.selectedAddress = chainChange.defaultAddress?.toJS;
        break;
      case JSEventType.disconnect:
        _stellar?.object.selectedAddress = null;
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
  JSClientType get _client => JSClientType.stellar;
}
