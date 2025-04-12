part of '../scripts.dart';

class SolanaPageController extends WalletStandardPageController {
  SolanaPageController(super.postMessage);

  @override
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    final signAndSendTransaction = _signAndSendTransaction.toJS;
    final signTransaction = _signTranaction.toJS;
    final signMessage = _signMessage.toJS;
    feature.solanaSignTransaction =
        SolanaWalletAdapterSolanaSignTransactionFeature.setup(
            signTransaction: signTransaction,
            supportedTransactionVersions:
                SolanaJSConstant.solanaTransactionVersion);
    feature.solanaSignAndSendTransaction =
        SolanaWalletAdapterSolanaSignAndSendTransactionFeature.setup(
            signAndSendTransaction: signAndSendTransaction);
    feature.solanaSignMessage =
        SolanaWalletAdapterSolanaSignMessageFeature.setup(
            signMessage: signMessage);
    feature.solanaSignAndSendAllTransactions =
        SolanaWalletAdapterSolanaSignAndSendAllTransactionsFeature.setup(
            signAndSendAllTransactions: _signAndSendAllTransactions.toJS);
    feature.solanaEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
    feature.solanaConnect =
        JSSolanaWalletStandardConnectFeature.setup(connect: _connect.toJS);
    feature.solanaSignIn =
        SolanaWalletAdapterSolanaSignInFeature.setup(signIn: _signIn.toJS);
  }

  JSPromise<JSSolanaWalletStandardConnect> _connect() {
    return waitForSuccessResponsePromise<JSSolanaWalletStandardConnect>(
        method: SolanaJSConstant.requestAccounts);
  }

  JSPromise<JSSolanaSignInResponse> _signIn(JSSolanaSignInParams params) {
    return waitForSuccessResponse<JSSolanaSignInResponse>(
            method: SolanaJSConstant.signInMessage,
            params: JsUtils.asJSArray(params))
        .toPromise;
  }

  JSPromise<JSArray<JSSolanaSignInResponse>> _signMessage(
      JSSolanaSignMessageParams params) {
    return waitForSuccessResponse<JSArray<JSSolanaSignInResponse>>(
            method: SolanaJSConstant.signMessage,
            params: JsUtils.asJSArray(params))
        .toPromise;
  }

  JSPromise<JSArray<SolanaSignTransactionOutput>> _signTranaction(
      JSAny transaction) {
    return waitForSuccessResponse<JSArray<SolanaSignTransactionOutput>>(
            method: SolanaJSConstant.signTransaction,
            params: JsUtils.asJSArray(transaction))
        .toPromise;
  }

  JSPromise<JSArray<SolanaSignAndSendTransactionOutput>>
      _signAndSendTransaction(
          JSSolanaSignAndSendTransactionParams transaction) {
    return waitForSuccessResponsePromise<
            JSArray<SolanaSignAndSendTransactionOutput>>(
        method: SolanaJSConstant.sendTransaction,
        params: JsUtils.asJSArray(transaction));
  }

  JSPromise<JSArray<SolanaSignAndSendTransactionOutput>>
      _signAndSendAllTransactions(
          JSArray<JSSolanaSignAndSendTransactionParams> transaction,
          [JSSolanaSignAndSendAllTransactionMode? options]) {
    return waitForSuccessResponsePromise<
            JSArray<SolanaSignAndSendTransactionOutput>>(
        method: SolanaJSConstant.signAndSendAllTransactions,
        params: [transaction, if (options.isDefinedAndNotNull) options!].toJS);
  }

  @override
  JSClientType get _client => JSClientType.solana;
}
