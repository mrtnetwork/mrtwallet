part of '../scripts.dart';

class EthereumPageController extends PageNetworkController {
  int _requestId = 0;
  ProxyMethodHandler<EIP1193>? _ethereum;

  EthereumPageController();

  ProxyMethodHandler<EIP1193> _setupEIP() {
    final eip = EIP1193.setup(
        request: _onRequest.toJS,
        on: _addListener.toJS,
        removeListener: _removeListener.toJS,
        disconnect: _disconnect.toJS,
        enable: _enable.toJS,
        cancelAllListener: _cancelAllListeners.toJS,
        onWalletRequest: _onWalletRequest.toJS);
    return ProxyMethodHandler(eip);
  }

  void _init() {
    _ethereum ??= _setupEIP();
    final proxy = Proxy(_ethereum!.object, createJSInteropWrapper(_ethereum!));
    ethereum = proxy;
    EIP6963ProviderDetail.setup(proxy);
  }

  void _disable(String? message) {
    ethereum = null;
    jsConsole.error(message);
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final connectionInfo = ProviderConnectInfo.fromJson(message.asMap());
        eventData = connectionInfo.toJSEvent;
        _ethereum?.object.chainId = connectionInfo.chainId;
        _ethereum?.object.networkVersion = connectionInfo.netVersion.toString();
        break;
      case JSEventType.chainChanged:
        final connectionInfo = ProviderConnectInfo.fromJson(message.asMap());
        eventData = connectionInfo.chainId.jsify();
        _ethereum?.object.chainId = connectionInfo.chainId;
        _ethereum?.object.networkVersion = connectionInfo.netVersion.toString();
        break;
      case JSEventType.disconnect:
        _ethereum?.object.chainId = null;
        _ethereum?.object.networkVersion = null;
        _ethereum?.object.selectedAddress = null;
        break;
      case JSEventType.accountsChanged:
        final changeInfo = EthereumAccountsChanged.fromJson(message.asMap());

        eventData = changeInfo.toJSEvent;
        _ethereum?.object.selectedAddress = changeInfo.defaultAddress?.toJS;
        break;
      case JSEventType.disable:
        _disable(message.asString());
        break;
      case JSEventType.active:
        _init();
        break;
      default:
    }
    _eventListeners(message.eventType, jsObject: eventData);
  }

  void _eventListeners(JSEventType type, {JSAny? jsObject}) {
    if (jsObject == null || !_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _disconnect() {}

  void _addListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null) return;
    _listeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _cancelAllListeners() {
    for (final i in _listeners.keys.toList()) {
      _listeners[i]!.clear();
    }
  }

  void _removeListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _listeners[event]?.remove(listener);
  }

  JSPromise<JSAny?> _enable() {
    final params = EthereumRequestParams(method: "eth_requestAccounts");
    return _onRequest(params);
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    final message = PageMessageRequest.create(
        method: params.method,
        params: params.params,
        id: (_requestId++).toString());
    final promise = _onNetworkRequest(message).toPromise;
    return promise;
  }

  @override
  JSClientType get _client => JSClientType.ethereum;
}
