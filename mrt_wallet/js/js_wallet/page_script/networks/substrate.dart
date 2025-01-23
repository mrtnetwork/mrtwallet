part of '../scripts.dart';

class _SubstratePageControllerConst {
  static const String signMesssage = 'substrate_signMessage';
  static const String addSubstrateChain = 'wallet_addSubstrateChain';
  static const String signTransaction = 'substrate_signTransaction';
  static final Web3JSRequestParams knownMetadata =
      Web3JSRequestParams(method: "substrate_knownMetadata");
  static final requestAccount =
      Web3JSRequestParams(method: "substrate_requestAccounts");
}

class SubstratePageController extends PageNetworkController {
  SubstratePageController(super.postMessage);

  final Map<JSEventType, List<JSFunction>> _networkListener = {
    JSEventType.accountsChanged: [],
  };
  ProxyMethodHandler<SubstrateWalletAdapter>? _substrate;
  Proxy<SubstrateWalletAdapter>? _proxy;
  ProxyMethodHandler<SubstrateWalletAdapter> _createAdapter() {
    final metadata = JSSubstrateWalletAdapterMetadata(JSObject());
    final accounts = JSSubstrateWalletAdapterAccounts(JSObject());
    final signer = JSSubstrateWalletAdapterSigner(JSObject());
    final adapter = SubstrateWalletAdapter(JSObject());
    signer.signPayload = sign.toJS;
    signer.signRaw = signRaw.toJS;
    signer.update = update.toJS;
    metadata.get = _metadataGet.toJS;
    metadata.provide = _metadataProvide.toJS;
    accounts.get = _requestAccount.toJS;
    accounts.subscribe = _listenAccount.toJS;
    adapter.on = _addListener.toJS;
    adapter.disconnect = _disconnectChain.toJS;
    adapter.removeListener = _removeListener.toJS;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _postWalletRequest.toJS;
    adapter.cancelAllListener = _cancelAllListeners.toJS;
    adapter.metadata = metadata.toProxy(debugKey: "Metadata: ");
    adapter.accounts = accounts.toProxy(debugKey: "Accounts: ");
    adapter.signer = signer.toProxy(debugKey: "Signer: ");
    adapter.connect = _enable.toJS;
    adapter.enable = _enable.toJS;
    adapter.name = JSWalletConstant.name;
    adapter.version = JSWalletConstant.version;

    return ProxyMethodHandler<SubstrateWalletAdapter>(adapter,
        debugKey: "Substrate: ");
  }

  JSPromise<JSAny?> sign(JSSubstrateTransaction transaction) {
    final params = Web3JSRequestParams(
        method: _SubstratePageControllerConst.signTransaction,
        params: [transaction].toJS);
    return _postNetworkRequest(params);
  }

  JSPromise<JSAny?> signRaw(JSSubstrateSign message) {
    final params = Web3JSRequestParams(
        method: _SubstratePageControllerConst.signMesssage,
        params: [message].toJS);
    return _postNetworkRequest(params);
  }

  JSPromise<JSAny?> update(JSAny? params) {
    throw JSWalletConstant.methodDisabled;
  }

  JSPromise<JSAny?> _metadataGet([bool? any]) {
    return _postNetworkRequest(_SubstratePageControllerConst.knownMetadata);
  }

  JSPromise<JSAny?> _metadataProvide(JSSubstrateMetadataProvide data) {
    final params = Web3JSRequestParams(
        method: _SubstratePageControllerConst.addSubstrateChain,
        params: [data].toJS);
    return _postNetworkRequest(params);
  }

  void _listenAccount(JSFunction cb) {
    _networkListener[JSEventType.accountsChanged]!.add(cb);
    _emitEvent(PageMessageEvent.build(event: JSEventType.accountsChanged));
  }

  Future<Proxy?> _connect() async {
    return _proxy;
  }

  JSPromise<Proxy?> _enable(String origin) {
    return _connect().toPromise;
  }

  void _initController() {
    _substrate ??= _createAdapter();
    _proxy ??= Proxy<SubstrateWalletAdapter>(
        _substrate!.object, createJSInteropWrapper(_substrate!));
    if (injectedWeb3Nullable == null) {
      injectedWeb3 = JSInjectedWeb3(JSObject());
    }
    injectedWeb3.mrt = _proxy;
    substrate = _proxy;
  }

  JSPromise<JSAny?> _requestAccount([JSAny? data]) {
    return _postNetworkRequest(_SubstratePageControllerConst.requestAccount);
  }

  void _disable({String? message}) {
    substrate = null;
    jsConsole.error(message);
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final chainChange = message.data as JSSubstrateProviderConnectInfo;
        eventData = chainChange.genesis.toJS;
        break;
      case JSEventType.chainChanged:
        eventData = message.data;
        break;
      case JSEventType.accountsChanged:
        final chainChange = message.data as JSSubstrateAccountsChanged;
        eventData = chainChange.accounts.toDart
            .map((e) => e.address.toJS)
            .toList()
            .toJS;
        _substrate?.object.selectedAddress =
            chainChange.defaultAddress?.address.toJS;
        _eventNetworkListeners(chainChange.accounts);
        break;
      case JSEventType.disconnect:
        _substrate?.object.selectedAddress = null;
        break;
      case JSEventType.disable:
        _disable(message: message.asString());
        return;
      case JSEventType.active:
        _initController();
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
      i.callAsFunction(null, jsObject);
    }
  }

  void _eventNetworkListeners(JSAny? jsObject) {
    if (jsObject == null) return;
    final listeners = <JSFunction>[
      ..._networkListener[JSEventType.accountsChanged]!
    ];
    for (final i in listeners) {
      i.callAsFunction(null, jsObject);
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
  JSClientType get _client => JSClientType.substrate;
}
