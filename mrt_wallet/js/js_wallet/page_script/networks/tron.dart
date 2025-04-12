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
      "message": {
        "action": action,
        "data": data,
      },
      "source": "contentScript",
    };
  }

  static Map<String, dynamic> buildUpdateNodeEvent(
      JSTronTIPChainChanged? node) {
    return buildEventMessage(action: "setNode", data: {"node": node});
  }

  static void postAddress(JSSTronWalletAccount? address) {
    jsWindow.postMessage(
      _TronPageControllerConst.buildEventMessage(
              action: "accountsChanged", data: address)
          .jsify(),
    );
  }

  static void postChainChanged(JSTronTIPChainChanged? node) {
    jsWindow.postMessage(
        _TronPageControllerConst.buildUpdateNodeEvent(node).jsify());
  }

  static void postConnect() {
    jsWindow.postMessage(
      _TronPageControllerConst.buildEventMessage(action: "connect").jsify(),
    );
  }

  static void checkIsPrivateKey(JSAny? privateKey) {
    if (privateKey.isA<JSString>()) {
      final key = (privateKey as JSString).toDart;
      if (key.length == 64 || key.length == 66) {
        throw JSWalletError(
            message: _TronPageControllerConst.providedPrivateKeyError);
      }
    }
  }
}

class TronPageController extends WalletStandardPageController {
  TIP1193? _tron;
  TronWeb? _tronWeb;
  final JSTronAddress _address =
      JSTronAddress(base58: false.toJS, hex: false.toJS);
  TronPageController(super.postMessage);

  final Map<JSEventType, List<JSFunction>> _tipListeners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
    JSEventType.connect: [],
    JSEventType.disconnect: []
  };

  TIP1193 _setupTIP1193(Proxy<TronWeb> tronWeb) {
    return TIP1193.setup(
        request: _onRequest.toJS,
        on: _addTIPListener.toJS,
        enable: _enable.toJS,
        removeListener: _removeTIPListener.toJS,
        disconnect: _disconnectChain.toJS,
        tronWeb: tronWeb,
        params: TronLinkParams(JSObject())
          ..dappIcon = ''
          ..dappName = ''
          ..openTronLinkAppOnMobile = true
          ..openUrlWhenWalletNotFound = true);
  }

  void _setNode(String fullNodeUri) {
    _tronWeb?.fullNode = HttpProvider(fullNodeUri);
    _tronWeb?.solidityNode = HttpProvider(fullNodeUri);
    _tronWeb?.setEventServer(HttpProvider(fullNodeUri));
  }

  void _initController() {
    final tronWeb = TronWeb.defaultTronWeb();
    final defaultAddr = ProxyMethodHandler<JSTronAddress>(_address);
    final defaultAddressProxy = Proxy<JSTronAddress>(
        defaultAddr.object, createJSInteropWrapper(defaultAddr));
    tronWeb.trx.signTransaction__ = _signTransaction_.toJS;
    tronWeb.trx.signMessageV2__ = _signMessageV2.toJS;
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
    final adapter = _setupTIP1193(tronWeb.toProxy());
    tronLink = adapter.toProxy();
    tronWeb_ = tronWeb.toProxy();
    tron = adapter.toProxy();
    _tron = adapter;
    _tronWeb = tronWeb;
  }

  void _disabledFeature(JSAny? args) {
    throw JSWalletConstant.methodDisabled;
  }

  JSPromise<JSString> _signMessageV2(JSAny message, [JSAny? privateKey]) {
    if (privateKey.isDefinedAndNotNull) {
      _TronPageControllerConst.checkIsPrivateKey(privateKey);
    }
    return waitForSuccessResponsePromise(
      method: _TronPageControllerConst.signMessage,
      params: [message].toJS,
      provider: PageRequestType.eip1993,
    );
  }

  JSPromise<JSObject> _signTransaction_(JSAny message, [JSAny? privateKey]) {
    if (privateKey.isDefinedAndNotNull) {
      _TronPageControllerConst.checkIsPrivateKey(privateKey);
    }
    return waitForSuccessResponsePromise(
      method: _TronPageControllerConst.signTransaction,
      params: [message].toJS,
      provider: PageRequestType.eip1993,
    );
  }

  JSPromise<JSAny?> _multiSign(JSAny message, [JSAny? privateKey]) {
    if (privateKey.isDefinedAndNotNull) {
      _TronPageControllerConst.checkIsPrivateKey(privateKey);
    }
    return waitForSuccessResponsePromise(
      method: _TronPageControllerConst.signTransaction,
      params: [message].toJS,
      provider: PageRequestType.eip1993,
    );
  }

  void _eventTIPListeners(JSEventType type, {JSAny? jsObject}) {
    if (jsObject == null || !_tipListeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._tipListeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(null, jsObject);
    }
  }

  void _addTIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null) return;
    _tipListeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _removeTIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _tipListeners[event]?.remove(listener);
  }

  JSPromise<JSArray<JSString>> _enable() {
    return waitForSuccessResponsePromise(
      method: _TronPageControllerConst.requestAccount,
      provider: PageRequestType.eip1993,
    );
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    return waitForSuccessResponsePromise(
      method: params.method,
      params: params.params,
      provider: PageRequestType.eip1993,
    );
  }

  @override
  JSClientType get _client => JSClientType.tron;

  @override
  void onWalletEvent(WalletMessageEvent message) {
    super.onWalletEvent(message);
    final data = message.data as JSWalletNetworkEvent;
    final events = data.eventTypes;
    for (final event in events) {
      switch (event) {
        case JSNetworkEventType.defaultAccountChanged:
          final JSSTronWalletAccount? account =
              data.account as JSSTronWalletAccount?;
          if (_tron?.selectedAddress != account?.address) {
            _tron?.selectedAddress = account?.address;
            _address.setAddress(account);
            _TronPageControllerConst.postAddress(account);
          }
          break;
        case JSNetworkEventType.message:
          _eventTIPListeners(JSEventType.message, jsObject: data.message);
          break;
        case JSNetworkEventType.networkAccountsChanged:
          _eventTIPListeners(JSEventType.accountsChanged,
              jsObject: data.networkAccounts?.jsAddresses);

          break;
        case JSNetworkEventType.defaultChainChanged:
          final chainChanged = data.chainChanged as JSTronTIPChainChanged?;
          _tron?.chainId = chainChanged?.chainId;
          _tron?.networkVersion = chainChanged?.netVersion;

          if (data.disconnect != null) {
            _eventTIPListeners(JSEventType.disconnect,
                jsObject: data.disconnect);
          }
          if (chainChanged != null) {
            if (data.disconnect == null) {
              _eventTIPListeners(JSEventType.connect, jsObject: chainChanged);
              _TronPageControllerConst.postConnect();
            }
            _setNode(chainChanged.fullNode);
            _eventTIPListeners(JSEventType.chainChanged,
                jsObject: chainChanged.chainId.toJS);
            _TronPageControllerConst.postChainChanged(chainChanged);
          }

          break;
        default:
      }
    }
  }

  JSPromise<JSTronWalletStandardConnect> _connect() {
    return waitForSuccessResponsePromise<JSTronWalletStandardConnect>(
      method: _TronPageControllerConst.requestAccount,
    );
  }

  JSPromise<JSTronSignatureResponse> _signMessage(
      JSTronSignMessageParams params) {
    return waitForSuccessResponsePromise<JSTronSignatureResponse>(
      method: _TronPageControllerConst.signMessage,
      params: [params].toJS,
    );
  }

  JSPromise<JSTronWalletStandardTransactionResponse> _signTransaction(
      JSTronWalletStandardTransactionParams params) {
    return waitForSuccessResponsePromise<
        JSTronWalletStandardTransactionResponse>(
      method: _TronPageControllerConst.signTransaction,
      params: [params].toJS,
    );
  }

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    _initController();
    feature.tronConnect =
        TronWalletAdapterConnectFeature.setup(connect: _connect.toJS);
    feature.tronSignMessage = TronWalletAdapterSignMessageFeature.setup(
        signMessage: _signMessage.toJS);
    feature.tronSignTransaction = TronWalletAdapterSignTransactionFeature.setup(
        signAndSendTransaction: _signTransaction.toJS);
    feature.tronSignTransaction = TronWalletAdapterSignTransactionFeature.setup(
        signAndSendTransaction: _signTransaction.toJS);
    feature.tronEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }
}
