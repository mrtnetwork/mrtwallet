part of '../scripts.dart';

class SuiPageController extends PageNetworkController {
  SuiPageController(super.postMessage);
  SuiWalletAdapter? _sui;
  Proxy<SuiWalletAdapter>? _suiProxy;
  (Proxy<SuiWalletAdapter>, SuiWalletAdapter) _createAdapter() {
    final adapter = SuiWalletAdapter.setup();
    final features = SuiWalletAdapterFeatures(JSObject());

    features.connect = SuiWalletAdapterStandardConnectFeature.setup(
        connect: _requestAccount.toJS);
    features.signTransaction =
        SuiWalletAdapterStandardSignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
    features.signTransactionBlock =
        SuiWalletAdapterStandardSignTransactionBlockFeature.setup(
            signTransactionBlock: _signTransactionBlock.toJS);
    features.signAndExecuteTransactionBlock =
        SuiWalletAdapterStandardSignAndExecuteTransactionBlockFeature.setup(
            signAndExecuteTransactionBlock:
                _signAndExcuteTransactionBlock.toJS);
    features.signAndExecuteTransaction =
        SuiWalletAdapterStandardSignAndExecuteTransactionFeature.setup(
            signAndExecuteTransaction: _signAndExecuteTransaction.toJS);
    features.signPersonalMessage =
        SuiWalletAdapterStandardSignPersonalMessageFeature.setup(
            signPersonalMessage: _signPersonalMessage.toJS);
    features.signMessage = SuiWalletAdapterStandardSignMessageFeature.setup(
        signMessage: _signMessage.toJS);

    features.reportTransactionEffects =
        SuiWalletAdapterStandardReportTransactionEffectskFeature.setup(
            reportTransactionEffects: _reportTransactionEffects.toJS);
    features.disconnect = SuiWalletAdapterStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    features.events =
        SuiWalletAdapterStandardEventsFeature.setup(on: _onEvents.toJS);
    adapter.isConnected = false;
    adapter.sendWalletRequest = _buildWalletRequest.toJS;
    adapter.features = features.toProxy(debugKey: "features: ");
    adapter.name = JSWalletConstant.name;
    adapter.version = SuiJSConstant.version;
    adapter.icon = JSWalletConstant.mrtPngBase64;
    adapter.accounts = <JSSuiWalletAccount>[].toJS.freez;
    adapter.chains = SuiJSConstant.supportedChains.freez;
    adapter.disconnect = _disconnectChain.toJS;
    final proxy = adapter.toProxy(debugKey: "sui: ");
    final event = CustomEvent(
        SolanaJSConstant.walletStandardRegisterEvent,
        EventInit(
            bubbles: false,
            cancelable: false,
            detail: (StandardWalletAdapterRegisterEvent event) {
              event.register(proxy);
            }.toJS));
    jsWindow.addEventListener(
        SolanaJSConstant.walletStandardAppReadyEvent,
        (JSAny _) {
          jsWindow.dispatchEvent(event);
        }.toJS);
    jsWindow.dispatchEvent(event);
    return (proxy, adapter);
  }

  void _initController() {
    if (_sui == null) {
      final adapter = _createAdapter();
      _sui = adapter.$2;
      _suiProxy = adapter.$1;
    }
    sui = _suiProxy;
  }

  JSPromise<JSSuiSignMessageResponse> _signMessage(
      JSSuiSignMessageParams params) {
    final message = Web3JSRequestParams(
        method: SuiJSConstant.signMessageRequestName, params: [params].toJS);
    return _createAndPostNetworkRequestMessage<JSSuiSignMessageResponse>(
            message)
        .toPromise;
  }

  JSPromise<JSSuiSignPrsonalMessageResponse> _signPersonalMessage(
      JSSuiSignMessageParams params) {
    final message = Web3JSRequestParams(
        method: SuiJSConstant.signPersonalMessageRequestName,
        params: [params].toJS);
    return _createAndPostNetworkRequestMessage<JSSuiSignPrsonalMessageResponse>(
            message)
        .toPromise;
  }

  Future<T> _signTransction_<T extends JSAny>(
      {required JSSuiSignTransactionParams transaction,
      required String method}) async {
    final tx = await transaction.toRequest();
    final params = Web3JSRequestParams(method: method, params: [tx].toJS);
    final promise = await _createAndPostNetworkRequestMessage<T>(params);
    return promise;
  }

  JSPromise<JSSuiSignTransactionResponse> _signTransaction(
      JSSuiSignTransactionParams transaction) {
    return _signTransction_<JSSuiSignTransactionResponse>(
            method: SuiJSConstant.signTransactionRequestName,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSAny?> _signAndExecuteTransaction(
      JSSuiSignTransactionParams transaction) {
    return _signTransction_(
            method: SuiJSConstant.signAndExecuteTransaction,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSAny?> _signAndExcuteTransactionBlock(
      JSSuiSignTransactionParams transaction) {
    return _signTransction_(
            method: SuiJSConstant.signAndExecuteTransactionBlock,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSSuiSignTransactionBlockResponse> _signTransactionBlock(
      JSSuiSignTransactionParams transaction) {
    return _signTransction_<JSSuiSignTransactionBlockResponse>(
            method: SuiJSConstant.signTransactionBlockRequestName,
            transaction: transaction)
        .toPromise;
  }

  JSPromise _reportTransactionEffects(JSAny _) {
    return Future.delayed(Duration.zero).toJS;
  }

  JSPromise<JSAny?> _buildWalletRequest(Web3JSRequestParams request) {
    throw UnimplementedError("Qweqwe ");
  }

  JSPromise<JSSuiWalletConnectResponse> _requestAccount() {
    final params =
        Web3JSRequestParams(method: SuiJSConstant.requestAccountRequestName);
    return _postNetworkRequest(params);
  }

  void _disable({String? message}) {
    stellar = null;
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final chainChange = message.data as JSSuiNetworkInfo;
        _eventListeners(JSEventType.connect, chainChange);
        _eventListeners(JSEventType.chainChanged, chainChange);
        break;
      case JSEventType.chainChanged:
        final chainChange = message.data as JSSuiNetworkInfo;
        _eventListeners(JSEventType.chainChanged, chainChange);
        _eventListeners(JSEventType.change, chainChange);
        break;
      case JSEventType.accountsChanged:
        final chainChange = message.data as JSSuiAccountChanged;
        _sui?.selectedAddress = chainChange.defaultAddress?.address.toJS;
        _sui?.accounts = chainChange.accounts;
        _eventListeners(
            JSEventType.accountsChanged, chainChange.toWalletEvent());
        _eventListeners(JSEventType.change, chainChange);
        return;
      case JSEventType.disconnect:
        _sui?.selectedAddress = null;
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

  void _onEvents(JSString type, JSFunction listener) {
    final eventType = JSEventType.fromName(type.toDart);
    if (eventType != null) {
      _listeners[eventType]!.add(listener);
    }
    _emitEvent(PageMessageEvent.build(event: eventType!));
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

  @override
  JSClientType get _client => JSClientType.sui;
}
