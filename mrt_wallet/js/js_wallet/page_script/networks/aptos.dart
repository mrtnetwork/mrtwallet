part of '../scripts.dart';

class AptosPageController extends PageNetworkController {
  final Map<JSEventType, List<JSFunction>> _aptosLiteners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
  };
  AptosPageController(super.postMessage);
  ProxyMethodHandler<AptosWalletAdapter>? _aptos;
  ProxyMethodHandler<AptosWalletAdapter> _createAdapter() {
    final adapter = AptosWalletAdapter.setup();
    final listener = _addListener.toJS;
    final signTransaction = _signTransaction.toJS;
    final features = AptosWalletAdapterFeatures(JSObject());
    features.connect = AptosWalletAdapterStandardConnectFeature.setup(
        connect: _requestAccount.toJS);
    features.signTransaction =
        AptosWalletAdapterStandardSignTransactionFeature.setup(
      signTransaction: signTransaction,
    );
    features.signMessage = AptosWalletAdapterStandardSignMessageFeature.setup(
        signMessage: _signMessage.toJS);
    features.account = AptosWalletAdapterStandardAccountFeature.setup(
        account: _requestAccount.toJS);
    features.onNetworkChange =
        AptosWalletAdapterStandardOnNetworkChangeFeature.setup(
            onNetworkChange: _onNetworkChange.toJS);
    features.network = AptosWalletAdapterStandardGetNetworkFeature.setup(
        network: _network.toJS);
    features.onAccountChange =
        AptosWalletAdapterStandardOnAccountChangeFeature.setup(
            onAccountChange: _onAccountChange.toJS);
    features.disconnect = AptosWalletAdapterStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    features.changeNetwork =
        AptosWalletAdapterStandardChangeNetworkFeature.setup(
            changeNetwork: _changeNetwork.toJS);
    adapter.removeListener = _removeListener.toJS;
    adapter.connect = _connect.toJS;
    adapter.isConnected = false;
    adapter.on = listener;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _buildWalletRequest.toJS;

    adapter.features = features.toProxy();
    adapter.name = JSWalletConstant.name;
    adapter.version = AptosJSConstant.version;
    adapter.icon = JSWalletConstant.mrtPngBase64;
    adapter.accounts = <JSAptosWalletAccount>[].toJS.freez;
    adapter.chains = AptosJSConstant.supportedChains.freez;
    adapter.disconnect = _disconnectChain.toJS;
    final event = CustomEvent(
        SolanaJSConstant.walletStandardRegisterEvent,
        EventInit(
            bubbles: false,
            cancelable: false,
            detail: (StandardWalletAdapterRegisterEvent event) {
              event.register(adapter);
            }.toJS));
    jsWindow.addEventListener(
        SolanaJSConstant.walletStandardAppReadyEvent,
        (JSAny _) {
          jsWindow.dispatchEvent(event);
        }.toJS);
    jsWindow.dispatchEvent(event);
    return ProxyMethodHandler<AptosWalletAdapter>(adapter);
  }

  void _initController() {
    _aptos ??= _createAdapter();
    final proxy = Proxy(_aptos!.object, createJSInteropWrapper(_aptos!));
    aptos = proxy;
  }

  JSPromise<JSAptosWalletStandardUserResponse> _changeNetwork(
      JSAptosNetworkInfo message) {
    final params = Web3JSRequestParams(
        method: AptosJSConstant.changeNetworkRequestName,
        params: [message].toJS);
    return _postNetworkRequest(params);
  }

  JSPromise<JSAptosWalletStandardUserResponse> _signMessage(
      JSAptosSignMessageParams message) {
    final params = Web3JSRequestParams(
        method: AptosJSConstant.signMessageRequestName, params: [message].toJS);
    return _signMessageRequest(params).toPromise;
  }

  Future<JSAptosWalletStandardUserResponse> _signTransactionRequest(
      Web3JSRequestParams params) async {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = await _postNetworkRequestMessage(message);
    final r = promise as JSAptosWalletStandardUserResponse;
    if (r.type.isRejected) return r;
    final signingResponse = r.args as JSAptosSignTransactionResponse;
    signingResponse.buildSerializable();
    return JSAptosWalletStandardUserResponse.approved(signingResponse);
  }

  JSPromise<JSAptosWalletStandardUserResponse> _connect() {
    final params =
        Web3JSRequestParams(method: AptosJSConstant.requestAccountRequestName);
    return _requestAccount_(params).toPromise;
  }

  Future<JSAptosWalletStandardUserResponse> _signMessageRequest(
      Web3JSRequestParams params) async {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = await _postNetworkRequestMessage(message);
    final r = promise as JSAptosWalletStandardUserResponse;
    if (r.type.isRejected) return r;
    final signingResponse = r.args as JSAptosSignMessageResponse;
    signingResponse.buildSerializable();
    return JSAptosWalletStandardUserResponse.approved(signingResponse);
  }

  JSPromise<JSAptosWalletStandardUserResponse> _signTransaction(
      JSAptosSignTransactionParams transaction) {
    final params = Web3JSRequestParams(
        method: "aptos_signTransaction",
        params: [transaction.toRequest()].toJS);
    return _signTransactionRequest(params).toPromise;
  }

  JSPromise<JSAny?> _buildWalletRequest(Web3JSRequestParams request) {
    throw UnimplementedError("Qweqwe ");
  }

  Future<JSAptosWalletStandardUserResponse> _requestAccount_(
      Web3JSRequestParams params) async {
    final message =
        PageMessageRequest.create(method: params.method, params: params.params);
    final promise = await _postNetworkRequestMessage(message);
    final r = promise as JSAptosWalletStandardUserResponse;
    if (r.type.isRejected) return r;
    final signingResponse = r.args as JSAptosWalletAccount;
    signingResponse.publicKey.buildSerializable();
    signingResponse.publicKey = signingResponse.publicKey.toProxy();
    return JSAptosWalletStandardUserResponse.approved(signingResponse);
  }

  JSPromise<JSAptosWalletStandardUserResponse> _requestAccount() {
    final params =
        Web3JSRequestParams(method: AptosJSConstant.requestAccountRequestName);
    return _requestAccount_(params).toPromise;
  }

  void _disable({String? message}) {
    stellar = null;
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final chainChange = message.data as JSAptosNetworkInfo;
        _eventListeners(JSEventType.connect, chainChange);
        _eventAptosListeners(JSEventType.chainChanged, chainChange);
        break;
      case JSEventType.chainChanged:
        final chainChange = message.data as JSAptosNetworkInfo;
        _eventListeners(JSEventType.chainChanged, chainChange);
        _eventAptosListeners(JSEventType.chainChanged, chainChange);
        break;
      case JSEventType.accountsChanged:
        final chainChange = message.data as JSAptosAccountChanged;
        _aptos?.object.selectedAddress =
            chainChange.defaultAddress?.address.toJS;
        _eventListeners(
            JSEventType.accountsChanged, chainChange.toWalletEvent());
        if (chainChange.defaultAddress != null) {
          _eventAptosListeners(
              JSEventType.accountsChanged, chainChange.defaultAddress!);
        }
        return;
      case JSEventType.disconnect:
        _aptos?.object.selectedAddress = null;
        _eventListeners(message.eventType, eventData);
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
  }

  void _onNetworkChange(JSFunction callBack) {
    _aptosLiteners[JSEventType.chainChanged]!.add(callBack);
    _emitEvent(PageMessageEvent.build(event: JSEventType.chainChanged));
  }

  JSPromise<JSAptosNetworkInfo> _network() {
    final message =
        Web3JSRequestParams(method: AptosJSConstant.getNetworkRequestName);
    return _postNetworkRequest<JSAptosNetworkInfo>(message);
  }

  void _onAccountChange(JSFunction callBack) {
    _aptosLiteners[JSEventType.accountsChanged]!.add(callBack);
    _emitEvent(PageMessageEvent.build(event: JSEventType.accountsChanged));
  }

  void _eventAptosListeners(JSEventType type, JSAny event) {
    if (!_aptosLiteners.containsKey(type)) return;
    _emit(_aptosLiteners[type]!, event);
  }

  void _emit(List<JSFunction> listeners, JSAny? message) {
    final clone = [...listeners];
    for (final i in clone) {
      i.callAsFunction(null, message);
    }
  }

  void _eventListeners(JSEventType type, JSAny? message) {
    if (!_listeners.containsKey(type)) return;
    _emit(_listeners[type]!, message);
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

  @override
  JSClientType get _client => JSClientType.aptos;
}
