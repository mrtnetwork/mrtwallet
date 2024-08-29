part of '../scripts.dart';

class TronPageController extends PageNetworkController {
  ProxyMethodHandler<TIP1193>? _tron;
  ProxyMethodHandler<TronWeb>? _tronWeb;
  TronPageController({required super.getWalletMessage});
  final Map<TronEventTypes, List<JSFunction>> _listeners = {
    TronEventTypes.accountsChanged: [],
    TronEventTypes.chainChanged: [],
    TronEventTypes.connect: [],
    TronEventTypes.message: [],
    TronEventTypes.disconnect: [],
  };
  ProxyMethodHandler<TIP1193> _setupTIP1193(Proxy tronWeb) {
    final eip = TIP1193.setup(
        request: _onRequest.toJS,
        on: _addListener.toJS,
        removeListener: _removeListener.toJS,
        disconnect: _disconnect.toJS,
        tronWeb: tronWeb,
        enable: _enable.toJS);
    return ProxyMethodHandler(eip);
  }

  void _init(TronWebNodeInfo info) {
    if (_tron != null) {
      _tronWeb?.object.fullNode = HttpProvider(info.fullNode);
      _tronWeb?.object.solidityNode = HttpProvider(info.fullNode);
      return;
    }
    final tronWeb = info.toTronWeb();
    final trxHandler = ProxyMethodHandler<TronWebTRX>(tronWeb.trx);
    tronWeb.trx.signTransaction__ = _signTransaction_.toJS;
    tronWeb.trx.signMessageV2__ = _signMessageV2_.toJS;
    tronWeb.trx.multiSignTransaction = _multiSign.toJS;
    tronWeb.setPrivateKey = _disabledFeature.toJS;
    tronWeb.setAddress = _disabledFeature.toJS;
    tronWeb.setFullNode = _disabledFeature.toJS;
    tronWeb.setSolidityNode = _disabledFeature.toJS;
    tronWeb.setAddress = _disabledFeature.toJS;
    tronWeb.setHeader = _disabledFeature.toJS;
    tronWeb.setFullNodeHeader = _disabledFeature.toJS;
    tronWeb.setDefaultBlock = _disabledFeature.toJS;
    tronWeb.trxx = Proxy(tronWeb.trx, createJSInteropWrapper(trxHandler));
    final tronWebMethodHandler = ProxyMethodHandler<TronWeb>(tronWeb);
    final adapter = _setupTIP1193(Proxy(tronWebMethodHandler.object,
        createJSInteropWrapper(tronWebMethodHandler)));
    final proxy = Proxy(adapter.object, createJSInteropWrapper(adapter));
    _tron = adapter;
    _tronWeb = tronWebMethodHandler;
    tron = proxy;
  }

  void _disabledFeature(JSAny? args) {
    throw Exception("this feature disabled by wallet provider.");
  }

  JSPromise<JSAny?> _signMessageV2_(JSAny message) {
    final params =
        TronRequestParams(method: "tron_signMessageV2", params: message);
    return _onRequest(params);
  }

  JSPromise<JSAny?> _signTransaction_(JSAny message) {
    final params =
        TronRequestParams(method: "tron_signTransaction", params: message);
    return _onRequest(params);
  }

  JSPromise<JSAny?> _multiSign(JSAny message) {
    final params =
        TronRequestParams(method: "tron_signTransaction", params: message);
    return _onRequest(params);
  }

  void _disableProvider(String? message) {
    tron = null;
    jsConsole.error(message);
  }

  void onEvent(JSWalletMessageResponseTron eventMessage) {
    JSAny? eventData;
    switch (eventMessage.event) {
      case TronEventTypes.connect:
        final connectionInfo =
            ProviderConnectInfo.fromJson(eventMessage.dataAs());
        _tron?.object.chainId = connectionInfo.chainId;
        eventData = connectionInfo.toJSEvent;
        break;
      case TronEventTypes.chainChanged:
        final connectionInfo =
            ProviderConnectInfo.fromJson(eventMessage.dataAs());
        _tron?.object.chainId = connectionInfo.chainId;
        eventData = connectionInfo.chainId.jsify();
        break;
      case TronEventTypes.disconnect:
        _tron?.object.chainId = null;
        break;
      case TronEventTypes.accountsChanged:
        final changeInfo = TronAccountsChanged.fromJson(eventMessage.dataAs());
        _tronWeb?.object.defaultAddress = changeInfo.defaultAddress == null
            ? null
            : createJSInteropWrapper(changeInfo.defaultAddress!);
        eventData = changeInfo.toJSEvenet;
        break;
      case TronEventTypes.disable:
        _disableProvider(eventMessage.dataAs());
        break;
      case TronEventTypes.active:
        final info = TronWebNodeInfo.fromJson(eventMessage.dataAs());
        _init(info);
        break;
      default:
    }
    _eventListeners(eventMessage.event, jsObject: eventData);
  }

  void _eventListeners(TronEventTypes type, {JSAny? jsObject}) {
    if (type == TronEventTypes.disconnect) return;
    if (jsObject == null || !_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _disconnect() {}

  void _addListener(String type, JSFunction listener) {
    final event = TronEventTypes.fromName(type);
    if (event == null) return;
    _listeners[event]?.add(listener);
    if (event != TronEventTypes.message && event != TronEventTypes.disconnect) {
      getWalletMessage(ClientMessageTron.event(event));
    }
  }

  void _removeListener(String type, JSFunction listener) {
    final event = TronEventTypes.fromName(type);
    _listeners[event]?.remove(listener);
  }

  JSPromise<JSAny?> _enable() {
    final params = TronRequestParams(method: "eth_requestAccounts");
    return _onRequest(params);
  }

  JSPromise<JSAny?> _onRequest(TronRequestParams params) {
    final message = ClientMessageTron(
        method: params.method, params: params.params?.dartify());
    final promise = getWalletMessage(message).toPromise;

    return promise;
  }
}
