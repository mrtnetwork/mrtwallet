part of '../scripts.dart';

class StellarPageController extends WalletStandardPageController {
  StellarPageController(super.postMessage);
  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.stellarSignAndSendTransaction =
        StellarWalletAdapterStellarSignAndSendTransactionFeature.setup(
            signAndSendTransaction: _sendTransaction.toJS);
    feature.stellarSignTransaction =
        StellarWalletAdapterStellarSignTransactionFeature.setup(
            signTransaction: _signTransaction.toJS);
    feature.stellarSignMessage =
        StellarWalletAdapterStellarSignMessageFeature.setup(
            signMessage: _signMessage.toJS);
    feature.stellarConnect =
        JSStellarWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.stellarEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  JSPromise<JSStellarWalletStandardConnect> _connect() {
    return waitForSuccessResponsePromise<JSStellarWalletStandardConnect>(
      method: StellarJSConst.requestAccounts,
    );
  }

  JSPromise<JSStellarSignTransactionResponse> _signTransaction(
      JSStellarSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise<JSStellarSignTransactionResponse>(
        method: StellarJSConst.signTransaction, params: [params].toJS);
  }

  JSPromise<JSStellarSendTransactionResponse> _sendTransaction(
      JSStellarSendOrSignTransactionParams params) {
    return waitForSuccessResponsePromise<JSStellarSendTransactionResponse>(
        method: StellarJSConst.sendTransaction, params: [params].toJS);
  }

  JSPromise<JSStellarSignMessageResponse> _signMessage(
      JSStellarSignMessageParams params) {
    return waitForSuccessResponsePromise<JSStellarSignMessageResponse>(
        method: StellarJSConst.signMessage, params: [params].toJS);
  }

  @override
  JSClientType get _client => JSClientType.stellar;
}
