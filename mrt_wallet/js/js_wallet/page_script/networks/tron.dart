part of '../scripts.dart';

class _TronPageControllerConst {
  static const String signMessage = "tron_signMessageV2";
  static const String signTransaction = "tron_signTransaction";
  static const String requestAccount = "tron_requestAccounts";
  static const String providedPrivateKeyError =
      "Please use static method `TronWeb.TRX.sign` for signing with own private key";
}

class TronPageController extends PageNetworkController {
  ProxyMethodHandler<TIP1193>? _tron;
  ProxyMethodHandler<TronWeb>? _tronWeb;
  TronPageController();

  ProxyMethodHandler<TIP1193> _setupTIP1193(Proxy tronWeb) {
    final eip = TIP1193.setup(
        request: _onRequest.toJS,
        on: _addListener.toJS,
        removeListener: _removeListener.toJS,
        disconnect: _disconnect.toJS,
        tronWeb: tronWeb,
        enable: _enable.toJS,
        cancelAllListener: _cancelAllListeners.toJS,
        sendWalletRequest: _onWalletRequest.toJS);
    return ProxyMethodHandler(eip);
  }

  void _init(TronWebNodeInfo info) {
    if (_tron != null && _tronWeb != null) {
      final proxy = Proxy(_tron!.object, createJSInteropWrapper(_tron!));
      tron = proxy;
    }
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
    tronWeb.trx_ = Proxy(tronWeb.trx, createJSInteropWrapper(trxHandler));
    final tronWebMethodHandler = ProxyMethodHandler<TronWeb>(tronWeb);
    final adapter = _setupTIP1193(Proxy(tronWebMethodHandler.object,
        createJSInteropWrapper(tronWebMethodHandler)));
    final proxy = Proxy(adapter.object, createJSInteropWrapper(adapter));
    _tron = adapter;
    _tronWeb = tronWebMethodHandler;
    tron = proxy;
  }

  void _disabledFeature(JSAny? args) {
    throw JSWalletError(message: "this feature disabled by wallet provider.");
  }

  JSPromise<JSAny?> _signMessageV2_(JSAny message, [String? privateKey]) {
    if (privateKey != null) {
      throw JSWalletError(
          message: _TronPageControllerConst.providedPrivateKeyError);
    }

    return _sendRequest(
        method: _TronPageControllerConst.signMessage,
        params: message.dartify());
  }

  JSPromise<JSAny?> _signTransaction_(JSAny message, [String? privateKey]) {
    if (privateKey != null) {
      throw JSWalletError(
          message: _TronPageControllerConst.providedPrivateKeyError);
    }
    return _sendRequest(
        method: _TronPageControllerConst.signTransaction,
        params: message.dartify());
  }

  JSPromise<JSAny?> _multiSign(JSAny message, [String? privateKey]) {
    if (privateKey != null) {
      throw JSWalletError(
          message: _TronPageControllerConst.providedPrivateKeyError);
    }
    return _sendRequest(
        method: _TronPageControllerConst.signTransaction,
        params: message.dartify());
  }

  void _disableProvider(String? message) {
    tron = null;
    jsConsole.error(message);
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final connectionInfo = TronChainChanged.fromJson(message.asMap());
        _tron?.object.chainId = connectionInfo.chainId;
        eventData = connectionInfo.toJSEvent;
        break;
      case JSEventType.chainChanged:
        final connectionInfo = TronChainChanged.fromJson(message.asMap());
        _tron?.object.chainId = connectionInfo.chainId;
        _tronWeb?.object.fullNode = HttpProvider(connectionInfo.fullNode);
        _tronWeb?.object.solidityNode = HttpProvider(connectionInfo.fullNode);
        eventData = connectionInfo.chainId.jsify();
        break;
      case JSEventType.disconnect:
        _tron?.object.chainId = null;
        _tronWeb?.object.defaultAddress = null;
        break;
      case JSEventType.accountsChanged:
        final changeInfo = TronAccountsChanged.fromJson(message.asMap());
        _tronWeb?.object.defaultAddress = changeInfo.defaultAddress == null
            ? null
            : createJSInteropWrapper(changeInfo.defaultAddress!);
        _tron?.object.selectedAddress = changeInfo.defaultAddress?.base58.toJS;
        eventData = changeInfo.toJSEvent;
        break;
      case JSEventType.disable:
        _disableProvider(message.asString());
        break;
      case JSEventType.active:
        final info = TronWebNodeInfo.fromJson(message.asMap());
        _init(info);
        break;
      default:
    }
    _eventListeners(message.eventType, jsObject: eventData);
  }

  void _eventListeners(JSEventType type, {JSAny? jsObject}) {
    if (type == JSEventType.disconnect) return;
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

  void _removeListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _listeners[event]?.remove(listener);
  }

  void _cancelAllListeners() {
    for (final i in _listeners.keys.toList()) {
      _listeners[i]!.clear();
    }
  }

  JSPromise<JSAny?> _enable() {
    return _sendRequest(method: _TronPageControllerConst.requestAccount);
  }

  JSPromise<JSAny?> _sendRequest({required String method, Object? params}) {
    final message = PageMessageRequest.create(
        method: method, params: [params?.jsify()].toJS);
    final promise = _onNetworkRequest(message).toPromise;

    return promise;
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = _onNetworkRequest(message).toPromise;

    return promise;
  }

  @override
  JSClientType get _client => JSClientType.tron;
}
