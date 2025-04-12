part of '../scripts.dart';

class SuiPageController extends WalletStandardPageController {
  SuiPageController(super.postMessage);

  JSPromise<JSSuiSignMessageResponse> _signMessage(
      JSSuiSignMessageParams params) {
    return waitForSuccessResponsePromise(
      method: SuiJSConstant.signMessageRequestName,
      params: [params].toJS,
    );
  }

  JSPromise<JSSuiSignPrsonalMessageResponse> _signPersonalMessage(
      JSSuiSignMessageParams params) {
    return waitForSuccessResponsePromise(
      method: SuiJSConstant.signPersonalMessageRequestName,
      params: [params].toJS,
    );
  }

  Future<T> _signTransction_<T extends JSAny>(
      {required JSSuiSignOrExcuteTransactionParams transaction,
      required String method}) async {
    final tx = await transaction.toRequest();
    return waitForSuccessResponse(
      method: method,
      params: [tx].toJS,
    );
  }

  JSPromise<JSSuiSignTransactionResponse> _signTransaction(
      JSSuiSignOrExcuteTransactionParams transaction) {
    return _signTransction_<JSSuiSignTransactionResponse>(
            method: SuiJSConstant.signTransactionRequestName,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSSuiSignAndExecuteTransactionResponse> _signAndExecuteTransaction(
      JSSuiSignOrExcuteTransactionParams transaction) {
    return _signTransction_<JSSuiSignAndExecuteTransactionResponse>(
            method: SuiJSConstant.signAndExecuteTransaction,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSSuiSignAndExecuteTransactionBlockResponse>
      _signAndExcuteTransactionBlock(
          JSSuiSignOrExcuteTransactionParams transaction) {
    return _signTransction_<JSSuiSignAndExecuteTransactionBlockResponse>(
            method: SuiJSConstant.signAndExecuteTransactionBlock,
            transaction: transaction)
        .toPromise;
  }

  JSPromise<JSSuiSignTransactionBlockResponse> _signTransactionBlock(
      JSSuiSignOrExcuteTransactionParams transaction) {
    return _signTransction_<JSSuiSignTransactionBlockResponse>(
            method: SuiJSConstant.signTransactionBlockRequestName,
            transaction: transaction)
        .toPromise;
  }

  JSPromise _reportTransactionEffects(JSAny _) {
    return Future.delayed(Duration.zero).toJS;
  }

  @override
  JSClientType get _client => JSClientType.sui;

  JSPromise<JSSuiWalletConnectResponse> _connect() {
    return waitForSuccessResponsePromise<JSSuiWalletConnectResponse>(
        method: SuiJSConstant.requestAccountRequestName);
  }

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.suiSignTransaction =
        SuiWalletAdapterStandardSignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
    feature.suiConnect =
        JSSuiWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.suiSignTransactionBlock =
        SuiWalletAdapterStandardSignTransactionBlockFeature.setup(
            signTransactionBlock: _signTransactionBlock.toJS);
    feature.suiSignAndExecuteTransactionBlock =
        SuiWalletAdapterStandardSignAndExecuteTransactionBlockFeature.setup(
            signAndExecuteTransactionBlock:
                _signAndExcuteTransactionBlock.toJS);
    feature.suiSignAndExecuteTransaction =
        SuiWalletAdapterStandardSignAndExecuteTransactionFeature.setup(
            signAndExecuteTransaction: _signAndExecuteTransaction.toJS);
    feature.suiSignPersonalMessage =
        SuiWalletAdapterStandardSignPersonalMessageFeature.setup(
            signPersonalMessage: _signPersonalMessage.toJS);
    feature.suiSignMessage = SuiWalletAdapterStandardSignMessageFeature.setup(
        signMessage: _signMessage.toJS);

    feature.suiReportTransactionEffects =
        SuiWalletAdapterStandardReportTransactionEffectskFeature.setup(
            reportTransactionEffects: _reportTransactionEffects.toJS);
    feature.suiDisconnect = SuiWalletAdapterStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    feature.suiEvents = JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }
}
