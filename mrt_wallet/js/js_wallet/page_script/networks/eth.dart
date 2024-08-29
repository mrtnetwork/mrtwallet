part of '../scripts.dart';

class EthereumPageController extends PageNetworkController {
  ProxyMethodHandler<EIP1193>? _ethereum;
  final Map<EthereumEvnetTypes, List<JSFunction>> _listeners = {
    EthereumEvnetTypes.accountsChanged: [],
    EthereumEvnetTypes.chainChanged: [],
    EthereumEvnetTypes.connect: [],
    EthereumEvnetTypes.message: [],
    EthereumEvnetTypes.disconnect: []
  };

  EthereumPageController({required super.getWalletMessage});

  ProxyMethodHandler<EIP1193> _setupEIP() {
    final eip = EIP1193.setup(
        request: _onRequest.toJS,
        on: _addListener.toJS,
        removeListener: _removeListener.toJS,
        disconnect: _disconnect.toJS,
        enable: _enable.toJS);
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

  void onEvent(JSWalletMessageResponseEthereum message) {
    final JSWalletMessageResponseEthereum eventMessage = message.cast();
    JSAny? eventData;
    switch (eventMessage.event) {
      case EthereumEvnetTypes.connect:
        final connectionInfo =
            ProviderConnectInfo.fromJson(eventMessage.dataAs());
        eventData = connectionInfo.toJSEvent;
        _ethereum?.object.chainId = connectionInfo.chainId;
        _ethereum?.object.networkVersion = connectionInfo.netVersion.toString();
        break;
      case EthereumEvnetTypes.chainChanged:
        final connectionInfo =
            ProviderConnectInfo.fromJson(eventMessage.dataAs());
        eventData = connectionInfo.chainId.jsify();
        _ethereum?.object.chainId = connectionInfo.chainId;
        _ethereum?.object.networkVersion = connectionInfo.netVersion.toString();
        break;
      case EthereumEvnetTypes.disconnect:
        _ethereum?.object.chainId = null;
        _ethereum?.object.networkVersion = null;
        _ethereum?.object.selectedAddress = null;
        break;
      case EthereumEvnetTypes.accountsChanged:
        final changeInfo =
            EthereumAccountsChanged.fromJson(eventMessage.dataAs());

        eventData = changeInfo.toJSEvent;
        _ethereum?.object.selectedAddress = changeInfo.defaultAddress?.toJS;
        break;
      case EthereumEvnetTypes.disable:
        _disable(eventMessage.dataAs());
        break;
      case EthereumEvnetTypes.active:
        _init();
        break;
      default:
    }
    _eventListeners(eventMessage.event, jsObject: eventData);
  }

  void _eventListeners(EthereumEvnetTypes type, {JSAny? jsObject}) {
    if (jsObject == null || !_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _disconnect() {}

  void _addListener(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    if (event == null) return;
    _listeners[event]?.add(listener);
    if (event != EthereumEvnetTypes.message &&
        event != EthereumEvnetTypes.disconnect) {
      getWalletMessage(ClientMessageEthereum.event(event));
    }
  }

  void _removeListener(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    _listeners[event]?.remove(listener);
  }

  JSPromise<JSAny?> _enable() {
    final params = EthereumRequestParams(method: "eth_requestAccounts");
    return _onRequest(params);
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    final message = ClientMessageEthereum(
        method: params.method, params: params.params?.dartify());
    final promise = getWalletMessage(message).toPromise;
    return promise;
  }
}
