part of '../scripts.dart';

class CosmosPageController extends WalletStandardPageController {
  CosmosPageController(super.postMessage);
  CosmosWalletAdapter? _cosmos;
  Proxy<CosmosWalletAdapter>? _cosmosProxy;
  (Proxy<CosmosWalletAdapter>, CosmosWalletAdapter) _createAdapter() {
    final adapter = CosmosWalletAdapter.setup();
    adapter.getOfflineSigner = _getOfflineSigner.toJS;
    adapter.getOfflineSignerOnlyAmino = _getOfflineSignerOnlyAmino.toJS;
    adapter.getOfflineSignerAuto = _getOfflineSignerAuto.toJS;
    return (adapter.toProxy(), adapter);
  }

  JSPromise<JSCosmosWalletStandardConnect> connect() {
    return waitForSuccessResponsePromise<JSCosmosWalletStandardConnect>(
        method: JSCosmosConst.requestAccount);
  }

  JSPromise<JSCosmosSignMessageResponse> _signMessage(
      JSCosmosSignMessageParams params) {
    return waitForSuccessResponsePromise(
      method: JSCosmosConst.signMessage,
      params: [params].toJS,
    );
  }

  Proxy<JSCosmosOfflineDirectSigner> _getOfflineSigner(String chainId,
      [JSCosmosSignOption? signOption]) {
    JSPromise<JSArray<JSCosmosWalletAccount>> requestAccount() {
      return waitForSuccessResponsePromise<JSArray<JSCosmosWalletAccount>>(
          method: JSCosmosConst.requestAccount, params: [chainId].toJS);
    }

    JSPromise<JSCosmosDirectSignResponse> signDirect(
        String signerAddress, JSCosmosSignDoc signDoc) {
      final request = JSCosmosSignDirectRequest.setup(
          signDoc: signDoc,
          signerAddress: signerAddress,
          chainId: chainId,
          signOption: signOption);
      return waitForSuccessResponsePromise<JSCosmosDirectSignResponse>(
          method: JSCosmosConst.signTransactionDirect, params: [request].toJS);
    }

    final signer = JSCosmosOfflineDirectSigner.setup(
        getAccounts: requestAccount.toJS,
        signDirect: signDirect.toJS,
        chainId: chainId);
    return signer.toProxy();
  }

  Proxy<JSCosmosOfflineAminoSigner> _getOfflineSignerOnlyAmino(String chainId,
      [JSCosmosSignOption? signOption]) {
    JSPromise<JSArray<JSCosmosWalletAccount>> requestAccount() {
      return waitForSuccessResponsePromise<JSArray<JSCosmosWalletAccount>>(
          method: JSCosmosConst.requestAccount, params: [chainId].toJS);
    }

    JSPromise<JSCosmosAminoSignResponse> signAmino(
        String signerAddress, JSCosmosStdSignDoc signDoc) {
      final request = JSCosmosSignAminoRequest.setup(
          signDoc: jsJson.stringify(signDoc),
          signerAddress: signerAddress,
          chainId: chainId,
          signOption: signOption);
      return waitForSuccessResponsePromise<JSCosmosAminoSignResponse>(
          method: JSCosmosConst.signTransactionAmino, params: [request].toJS);
    }

    final signer = JSCosmosOfflineAminoSigner.setup(
        getAccounts: requestAccount.toJS,
        signAmino: signAmino.toJS,
        chainId: chainId);
    return signer.toProxy();
  }

  Proxy<JSCosmosSigner> _signer(String chainId,
      [JSCosmosSignOption? signOption]) {
    return JSCosmosSigner.setup(
            direct: _getOfflineSigner(chainId),
            amino: _getOfflineSignerOnlyAmino(chainId),
            chainId: chainId)
        .toProxy();
  }

  JSPromise<Proxy<JSCosmosOfflineAminoSigner>> _getOfflineSignerAuto(
      String chainId) {
    throw UnimplementedError();
  }

  void _initController() {
    if (_cosmos == null) {
      final adapter = _createAdapter();
      _cosmos = adapter.$2;
      _cosmosProxy = adapter.$1;
    }
    cosmos = _cosmosProxy;
    getOfflineSigner = _getOfflineSigner.toJS;
    getOfflineSignerOnlyAmino = _getOfflineSignerOnlyAmino.toJS;
    getOfflineSignerAuto = _getOfflineSignerAuto.toJS;
  }

  @override
  JSClientType get _client => JSClientType.cosmos;

  JSPromise<JSBoolean> _addNewChain(CosmosAddNewChainParams params) {
    return waitForSuccessResponsePromise<JSBoolean>(
        method: JSCosmosConst.addNewChain, params: [params].toJS);
  }

  JSPromise<JSCosmosSignMessageResponse> _signTransaction(
      JSCosmosSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise(
      method: JSCosmosConst.signTransaction,
      params: [params].toJS,
    );
  }

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    _initController();
    feature.cosmosConnect =
        CosmosWalletAdapterConnectFeature.setup(connect: connect.toJS);
    feature.cosmosEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
    feature.cosmosSigner =
        CosmosWalletAdapterSignerFeature.setup(signer: _signer.toJS);
    feature.cosmosAddNewChain = CosmosWalletAdapterAddNewChainFeature.setup(
        addNewChain: _addNewChain.toJS);
    feature.cosmosSignMessage =
        CosmosWalletAdapterStandardSignMessageFeature.setup(
            signMessage: _signMessage.toJS);
    feature.cosmosSignTransaction =
        CosmosWalletAdapterStandardSignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
  }
}
