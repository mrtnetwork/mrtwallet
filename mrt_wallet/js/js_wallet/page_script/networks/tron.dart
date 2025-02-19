part of '../scripts.dart';

class _TronPageControllerConst {
  static const String signMessage = "tron_signMessageV2";
  static const String signTransaction = "tron_signTransaction";
  static const String requestAccount = "tron_requestAccounts";
  static const String providedPrivateKeyError =
      "Please use static method `TronWeb.TRX.sign` for signing with own private key";
  static Map<String, dynamic> buildEventMessage(
      {required String action, Object? data}) {
    return {
      "message": {"action": action, "data": data}
    };
  }

  static Map<String, dynamic> buildUpdateNodeEvent(TronChainChanged? node) {
    final data = node == null
        ? null
        : {
            "chainId": node.chainId,
            "fullNode": node.fullNode,
            "solidityNode": node.solidityNode,
            "eventServer": node.fullNode
          };
    return buildEventMessage(action: "setNode", data: data);
  }
}

class TronPageController extends PageNetworkController {
  ProxyMethodHandler<TIP1193>? _tron;
  ProxyMethodHandler<TronWeb>? _tronWeb;
  ProxyMethodHandler<JSTronAddress>? _address;
  TronPageController(super.postMessage);

  ProxyMethodHandler<TIP1193> _setupTIP1193(Proxy tronWeb) {
    final eip = TIP1193.setup(
        request: _onRequest.toJS,
        on: _addListener.toJS,
        removeListener: _removeListener.toJS,
        disconnect: _disconnectChain.toJS,
        tronWeb: tronWeb,
        enable: _enable.toJS,
        cancelAllListener: _cancelAllListeners.toJS,
        sendWalletRequest: _postWalletRequest.toJS,
        params: TronLinkParams(JSObject())
          ..dappIcon = ''
          ..dappName = ''
          ..openTronLinkAppOnMobile = true
          ..openUrlWhenWalletNotFound = true);
    return ProxyMethodHandler(eip);
  }

  void _setNode(String fullNodeUri) {
    _tronWeb?.object.fullNode = HttpProvider(fullNodeUri);
    _tronWeb?.object.solidityNode = HttpProvider(fullNodeUri);
    _tronWeb?.object.setEventServer(HttpProvider(fullNodeUri));
  }

  void _initController({TronWebNodeInfo? info}) {
    if (_tron != null) {
      if (info != null) {
        _setNode(info.fullNode);
      }
      return;
    }
    final tronWeb = info?.toTronWeb() ?? TronWeb.defaultTronWeb();
    final trxHandler = ProxyMethodHandler<TronWebTRX>(tronWeb.trx);
    final defaultAddr = ProxyMethodHandler<JSTronAddress>(
        JSTronAddress(base58: false.toJS, hex: false.toJS));
    final defaultAddressProxy = Proxy<JSTronAddress>(
        defaultAddr.object, createJSInteropWrapper(defaultAddr));
    tronWeb.trx.signTransaction__ = _signTransaction_.toJS;
    tronWeb.trx.signMessageV2__ = _signMessageV2_.toJS;
    tronWeb.trx.multiSignTransaction = _multiSign.toJS;
    tronWeb.setPrivateKey = _disabledFeature.toJS;
    tronWeb.setAddress = _disabledFeature.toJS;
    tronWeb.setFullNode = _disabledFeature.toJS;
    tronWeb.setSolidityNode = _disabledFeature.toJS;
    tronWeb.setHeader = _disabledFeature.toJS;
    tronWeb.setFullNodeHeader = _disabledFeature.toJS;
    tronWeb.setDefaultBlock = _disabledFeature.toJS;
    tronWeb.defaultPrivateKey = '';
    tronWeb.defaultAddress = defaultAddressProxy;
    tronWeb.trx_ = Proxy(tronWeb.trx, createJSInteropWrapper(trxHandler));
    final tronWebMethodHandler = ProxyMethodHandler<TronWeb>(tronWeb);
    final tronWebProxy = Proxy(tronWebMethodHandler.object,
        createJSInteropWrapper(tronWebMethodHandler));
    final adapter = _setupTIP1193(tronWebProxy);
    final proxy = Proxy(adapter.object, createJSInteropWrapper(adapter));
    tronLink = proxy;
    tronWeb_ = tronWebProxy;
    tron = proxy;
    _tron = adapter;
    _tronWeb = tronWebMethodHandler;
    _address = defaultAddr;
  }

  void postAddress(String? address) {
    jsWindow.postMessage(
      _TronPageControllerConst.buildEventMessage(
          action: "accountsChanged", data: {"address": address}).jsify(),
    );
  }

  void postChainChanged(TronChainChanged? node) {
    jsWindow.postMessage(
        _TronPageControllerConst.buildUpdateNodeEvent(node).jsify());
  }

  void postConnect() {
    jsWindow.postMessage(
      _TronPageControllerConst.buildEventMessage(action: "connect").jsify(),
    );
  }

  void _disabledFeature(JSAny? args) {
    throw JSWalletConstant.methodDisabled;
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

  JSPromise<JSAny?> _signTransaction_(JSAny message, [JSAny? privateKey]) {
    if (privateKey.isDefinedAndNotNull) {
      if (privateKey.isA<JSString>()) {
        final key = privateKey.dartify() as String;
        if (key.isNotEmpty) {
          throw JSWalletError(
              message: _TronPageControllerConst.providedPrivateKeyError);
        }
      }
    }
    return _sendRequest(
        method: _TronPageControllerConst.signTransaction,
        params: message.dartify());
  }

  JSPromise<JSAny?> _multiSign(JSAny message, [JSAny? privateKey]) {
    if (privateKey.isDefinedAndNotNull) {
      if (privateKey.isA<JSString>()) {
        final key = privateKey.dartify() as String;
        if (key.isNotEmpty) {
          throw JSWalletError(
              message: _TronPageControllerConst.providedPrivateKeyError);
        }
      }
    }
    return _sendRequest(
        method: _TronPageControllerConst.signTransaction,
        params: message.dartify());
  }

  void _disable({String? message}) {
    tron = null;
  }

  void onEvent(WalletMessageEvent message) {
    try {
      JSAny? eventData = message.data;
      switch (message.eventType) {
        case JSEventType.connect:
          final connectionInfo = TronChainChanged.fromJson(message.asMap());
          _tron?.object.chainId = connectionInfo.chainId;
          _address?.object.setAddress(connectionInfo.address);

          eventData = connectionInfo.toJSEvent;

          postConnect();
          break;
        case JSEventType.chainChanged:
          final connectionInfo = TronChainChanged.fromJson(message.asMap());
          _tron?.object.chainId = connectionInfo.chainId;
          _setNode(connectionInfo.fullNode);
          eventData = connectionInfo.toJSEvent;
          postChainChanged(connectionInfo);

          break;
        case JSEventType.disconnect:
          _tron?.object.chainId = null;
          _address?.object.setAddress(null);
          break;
        case JSEventType.accountsChanged:
          final changeInfo = TronAccountsChanged.fromJson(message.asMap());
          _address?.object.setAddress(changeInfo.defaultAddress);

          if (changeInfo.defaultAddress?.base58.isEmpty ?? true) {
            _tron?.object.selectedAddress = null;
          } else {
            _tron?.object.selectedAddress =
                changeInfo.defaultAddress?.base58.toJS;
          }
          eventData = changeInfo.toJSEvent;
          postAddress(changeInfo.defaultAddress?.base58);
          break;
        case JSEventType.disable:
          _disable(message: message.asString());
          break;
        case JSEventType.active:
          final info = TronWebNodeInfo.fromJson(message.asMap());
          _initController(info: info);
          break;
        default:
      }
      _eventListeners(message.eventType, jsObject: eventData);
    } catch (e) {}
  }

  void _eventListeners(JSEventType type, {JSAny? jsObject}) {
    if (type == JSEventType.disconnect) return;
    if (jsObject == null || !_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(null, jsObject);
    }
  }

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
    final promise = _postNetworkRequestMessage(message).toPromise;

    return promise;
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = _postNetworkRequestMessage(message).toPromise;
    return promise;
  }

  @override
  JSClientType get _client => JSClientType.tron;
}
