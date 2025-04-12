part of '../scripts.dart';

class EthereumPageController extends WalletStandardPageController {
  EIP1193? _ethereum;
  EthereumPageController(super.postMessage);

  final Map<JSEventType, List<JSFunction>> _eipListeners = {
    JSEventType.accountsChanged: [],
    JSEventType.chainChanged: [],
    JSEventType.connect: [],
    JSEventType.message: [],
    JSEventType.disconnect: [],
  };

  EIP1193 _createEIP1193() {
    return EIP1193.setup(
        enable: _connectEip.toJS,
        request: _onRequest.toJS,
        on: _addEIPListener.toJS,
        removeListener: _removeEIPListener.toJS,
        disconnect: _disconnectChain.toJS);
  }

  JSPromise<JSAny?> _onRequest(EthereumRequestParams params) {
    return waitForSuccessResponsePromise<JSAny?>(
        method: params.method,
        params: params.params,
        provider: PageRequestType.eip1993);
  }

  void _initController() {
    _ethereum ??= _createEIP1193();
    final proxy = _ethereum?.toProxy();
    ethereum = proxy;
    EIP6963.setup(proxy);
  }

  JSPromise<JSArray<JSString>> _connectEip() {
    return waitForSuccessResponsePromise<JSArray<JSString>>(
        method: JSEthereumConst.requestAccounts,
        provider: PageRequestType.eip1993);
  }

  JSPromise<JSEthereumWalletStandardConnect> _connect() {
    return waitForSuccessResponsePromise<JSEthereumWalletStandardConnect>(
        method: JSEthereumConst.requestAccounts);
  }

  JSPromise<JSString> _addNewChain(JSEthereumAddNewChainParams params) {
    return waitForSuccessResponsePromise<JSString>(
      method: JSEthereumConst.addChain,
      params: [params].toJS,
    );
  }

  JSPromise<JSEthereumSignatureResponse> _signTypesData(
      JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSEthereumSignatureResponse>(
      method: JSEthereumConst.typedData,
      params: [params].toJS,
    );
  }

  JSPromise<JSEthereumSignatureResponse> _signTypesDataV3(
      JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSEthereumSignatureResponse>(
      method: JSEthereumConst.typedDataV3,
      params: [params].toJS,
    );
  }

  JSPromise<JSEthereumSignatureResponse> _signTypesDataV4(
      JSEthereumSignTypedDataParams params) {
    return waitForSuccessResponsePromise<JSEthereumSignatureResponse>(
      method: JSEthereumConst.typedDataV4,
      params: [params].toJS,
    );
  }

  JSPromise<JSEthereumSignatureResponse> _personalSign(
      JSEthereumSignMessageParams params) {
    return waitForSuccessResponsePromise<JSEthereumSignatureResponse>(
        method: JSEthereumConst.personalSign, params: [params].toJS);
  }

  JSPromise<JSEthereumSendTransactionResponse> _sendTransaction(
      JSEthereumWalletStandardTransactionParams params) {
    return waitForSuccessResponsePromise<JSEthereumSendTransactionResponse>(
        method: JSEthereumConst.sendTransaction, params: [params].toJS);
  }

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    _initController();
    feature.ethereumConnect =
        EthereumWalletAdapterConnectFeature.setup(connect: _connect.toJS);
    feature.ethereumAddNewChain = EthereumWalletAdapterAddNewChainFeature.setup(
        addNewChain: _addNewChain.toJS);
    feature.ethereumsignTypedData =
        EthereumWalletAdapterSignTypedDataFeature.setup(
            signTypedData: _signTypesData.toJS);
    feature.ethereumsignTypedDataV3 =
        EthereumWalletAdapterSignTypedDataV3Feature.setup(
            signTypedDataV3: _signTypesDataV3.toJS);
    feature.ethereumsignTypedDataV4 =
        EthereumWalletAdapterSignTypedDataV4Feature.setup(
            signTypedDataV4: _signTypesDataV4.toJS);
    feature.ethereumPersonalSign =
        EthereumWalletAdapterPersonalSignFeature.setup(
            personalSign: _personalSign.toJS);
    feature.ethereumSendTransaction =
        EthereumWalletAdapterSendTransactionFeature.setup(
            sendTransaction: _sendTransaction.toJS);
    feature.ethereumRequest =
        EthereumWalletAdapteRequestFeature.setup(request: _onRequest.toJS);
    feature.ethereumEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  @override
  void onWalletEvent(WalletMessageEvent message) {
    super.onWalletEvent(message);
    final data = message.data as JSWalletNetworkEvent;
    final events = data.eventTypes;
    for (final event in events) {
      switch (event) {
        case JSNetworkEventType.defaultAccountChanged:
          _ethereum?.selectedAddress = data.account?.address;
          break;
        case JSNetworkEventType.message:
          _eventEIPListeners(JSEventType.message, jsObject: data.message);
          break;
        case JSNetworkEventType.networkAccountsChanged:
          _eventEIPListeners(JSEventType.accountsChanged,
              jsObject: data.networkAccounts?.jsAddresses);
          break;
        case JSNetworkEventType.defaultChainChanged:
          final chainChanged = data.chainChanged as JSEthereumEIPChainChanged?;
          _ethereum?.chainId = chainChanged?.chainId;
          _ethereum?.networkVersion = chainChanged?.netVersion;
          if (data.disconnect != null) {
            _eventEIPListeners(JSEventType.disconnect,
                jsObject: data.disconnect);
          }
          if (chainChanged != null) {
            if (data.disconnect == null) {
              _eventEIPListeners(JSEventType.connect, jsObject: chainChanged);
            }
            _eventEIPListeners(JSEventType.chainChanged,
                jsObject: chainChanged.chainId.toJS);
          }

          break;
        default:
      }
    }
  }

  void _eventEIPListeners(JSEventType type, {JSAny? jsObject}) {
    if (jsObject == null || !_eipListeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._eipListeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(null, jsObject);
    }
  }

  void _addEIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null) return;
    _eipListeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _removeEIPListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _eipListeners[event]?.remove(listener);
  }

  @override
  JSClientType get _client => JSClientType.ethereum;
}
