part of '../scripts.dart';

class BitcoinPageController extends WalletStandardPageController {
  BitcoinPageController(super.postMessage);
  void _initNetworkFeatures(JSWalletStandardFeature feature) {
    feature.bitcoinConnect =
        JSWalletStandardConnectFeature.setup(connect: _connect.toJS);
    // feature.bitcoinAccount =
    //     JSWalletStandardAccountFeature.setup(account: _account.toJS);
    feature.bitcoinSignPersonalMessage =
        JSWalletStandardSignPersonalMessageFeature.setup(
            signPersonalMessage: _bitcoinSignPersonalMessage.toJS);
    feature.bitcoinSignTransaction =
        JSWalletStandardSignTransactionFeature.setup(
            signTransaction: _bitcoinSignTransaction);
    feature.bitcoinSendTransaction =
        JSWalletStandardSendTransactionFeature.setup(
            sendTransaction: _bitcoinSendTransaction.toJS);
    feature.bitcoinDisconnect = JSWalletStandardDisconnectFeature.setup(
        disconnect: _disconnectChain.toJS);
    feature.bitcoinEvents =
        JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
  }

  JSPromise<JSWalletStandardConnect> _connect() {
    return waitForSuccessResponsePromise<JSWalletStandardConnect>(
        method: BitcoinJSConstant.requestAccountRequestName);
  }

  JSPromise<JSBitcoinSignMessageResponse> _bitcoinSignPersonalMessage(
      JSBitcoinSignMessageParams params) {
    return waitForSuccessResponsePromise<JSBitcoinSignMessageResponse>(
        method: BitcoinJSConstant.signPersonalMessageRequestName,
        params: [params].toJS);
  }

  JSPromise<JSBitcoinSignTransactionResponse> _bitcoinSignTransaction(
      JSBitcoinSignTransactionResponse params) {
    return waitForSuccessResponsePromise<JSBitcoinSignTransactionResponse>(
        method: BitcoinJSConstant.signTransactionRequestName,
        params: [params].toJS);
  }

  JSPromise<JSBitcoinSendTransactionResponse> _bitcoinSendTransaction(
      JSBitcoinSendTransactionParams params) {
    return waitForSuccessResponsePromise<JSBitcoinSendTransactionResponse>(
        method: BitcoinJSConstant.sendTransactionRequestName,
        params: [params].toJS);
  }

  @override
  JSClientType get _client => JSClientType.bitcoin;
}
