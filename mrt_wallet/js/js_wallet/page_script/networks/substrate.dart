part of '../scripts.dart';

class _SubstratePageControllerConst {
  static const String signMesssage = 'substrate_signMessage';
  static const String addSubstrateChain = 'wallet_addSubstrateChain';
  static const String signTransaction = 'substrate_signTransaction';
  static const String knownMetadata = 'substrate_knownMetadata';
  // static final Web3JSRequestParams knownMetadata =
  //     Web3JSRequestParams(method: "substrate_knownMetadata");
  static final requestAccount = 'substrate_requestAccounts';
}

class SubstratePageController extends WalletStandardPageController {
  SubstratePageController(super.postMessage);

  final Map<JSEventType, List<JSFunction>> _networkListener = {
    JSEventType.accountsChanged: []
  };
  ProxyMethodHandler<JSPolkadotJSWalletAdapter>? _substrate;
  Proxy<JSPolkadotJSWalletAdapter>? _proxy;

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    _initJsPolkadotAdapter();
    feature.substrateSignTransaction =
        SubstrateWalletAdapterSubstrateSignTransactionFeature.setup(
            signTransaction: signTransaction.toJS);
    feature.substrateSignMessage =
        SubstrateWalletAdapterSubstrateSignMessageFeature.setup(
            signMessage: signMessage.toJS);
    feature.substrateConnect =
        JSSubstrateWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.substrateEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  void _initJsPolkadotAdapter() {
    _substrate ??= _createAdapter();
    _proxy ??= Proxy<JSPolkadotJSWalletAdapter>(
        _substrate!.object, createJSInteropWrapper(_substrate!));
    if (injectedWeb3Nullable == null) {
      injectedWeb3 = JSInjectedWeb3(JSObject());
    }
    injectedWeb3.mrt = _proxy;
    substrate = _proxy;
  }

  ProxyMethodHandler<JSPolkadotJSWalletAdapter> _createAdapter() {
    final metadata = JSSubstrateWalletAdapterMetadata(JSObject());
    final accounts = JSSubstrateWalletAdapterAccounts(JSObject());
    final signer = JSSubstrateWalletAdapterSigner(JSObject());
    final adapter = JSPolkadotJSWalletAdapter(JSObject());
    signer.signPayload = signTransaction.toJS;
    signer.signRaw = signMessage.toJS;
    signer.update = update.toJS;
    metadata.get = _knownMetadata.toJS;
    metadata.provide = _metadataProvide.toJS;
    accounts.get = _connectProvider.toJS;
    accounts.subscribe = _listenAccount.toJS;
    adapter.metadata = metadata.toProxy();
    adapter.accounts = accounts.toProxy();
    adapter.signer = signer.toProxy();
    adapter.connect = _enable.toJS;
    adapter.enable = _enable.toJS;
    adapter.name = JSWalletConstant.name;
    adapter.version = JSWalletConstant.version;

    return ProxyMethodHandler<JSPolkadotJSWalletAdapter>(adapter);
  }

  JSPromise<JSSubstrateKownMetadata> _knownMetadata([bool? _]) {
    return waitForSuccessResponsePromise(
      method: _SubstratePageControllerConst.knownMetadata,
    );
  }

  JSPromise<JSBoolean> _metadataProvide(JSSubstrateMetadataProvide params) {
    return waitForSuccessResponsePromise(
      method: _SubstratePageControllerConst.addSubstrateChain,
      params: [params].toJS,
    );
  }

  JSPromise<JSSubstrateTxResponse> signTransaction(
      JSSubstrateTransaction transaction) {
    return waitForSuccessResponsePromise(
      method: _SubstratePageControllerConst.signTransaction,
      params: [transaction].toJS,
    );
  }

  JSPromise<JSSubstrateTxResponse> signMessage(JSSubstrateSign params) {
    return waitForSuccessResponsePromise(
      method: _SubstratePageControllerConst.signMesssage,
      params: [params].toJS,
    );
  }

  JSPromise<JSSubstrateWalletStandardConnect> _connect([JSAny? _]) {
    return waitForSuccessResponsePromise(
      method: _SubstratePageControllerConst.requestAccount,
    );
  }

  JSPromise<JSArray<JSSubstrateWalletAccount>> _connectProvider([JSAny? _]) {
    return waitForSuccessResponse<JSSubstrateWalletStandardConnect>(
      method: _SubstratePageControllerConst.requestAccount,
    ).then((e) => e.accounts).toPromise;
  }

  JSPromise update([JSAny? _]) {
    throw JSWalletConstant.methodDisabled;
  }

  JSPromise<Proxy<JSPolkadotJSWalletAdapter>?> _enable(String origin) {
    Future<Proxy<JSPolkadotJSWalletAdapter>?> connect() async {
      return _proxy;
    }

    return connect().toPromise;
  }

  void _listenAccount(JSFunction cb) {
    _networkListener[JSEventType.accountsChanged]!.add(cb);
    _emitEvent(PageMessageEvent.build(event: JSEventType.accountsChanged));
  }

  @override
  JSClientType get _client => JSClientType.substrate;
}
