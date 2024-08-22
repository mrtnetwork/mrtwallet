part of '../scripts.dart';

@JS("tron")
external set tron(TronJSWalletAdapter tron);
mixin TronJScontroller on JSBasePageController {
  final Map<TronEventTypes, List<JSFunction>> _tronEventListeners = {
    TronEventTypes.accountsChanged: [],
    TronEventTypes.chainChanged: [],
    TronEventTypes.connect: [],
    TronEventTypes.message: [],
    TronEventTypes.disconnect: [],
  };

  void _initTron() {
    final adapter = TronJSWalletAdapter(JSObject());
    final trx = TronJSWalletTRX(JSObject());
    trx.signTransaction_ = _signTransaction.toJS;
    trx.signMessageV2_ = _signMessageV2.toJS;
    final tronLink = TronJSLinkWallet(JSObject());
    tronLink.trx = trx;
    adapter.request = _onTronRequest.toJS;
    adapter.tronWeb = tronLink;
    adapter.on = _onTronEvent.toJS;
    adapter.removeListener = _removeTronEvent.toJS;
    adapter.isTronLink = true;
    tron = adapter;
  }

  // wallet.on('chainChanged', this._onChainChanged);
  //   wallet.on('accountsChanged', this._onAccountsChanged);
  void _onTronEvent(String type, JSFunction listener) {
    final event = TronEventTypes.fromName(type);
    if (event == null) return;
    _tronEventListeners[event]?.add(listener);
    // if (event != EthereumEvnetTypes.message &&
    //     event != EthereumEvnetTypes.disconnect) {
    //   _getEventResult(event).then((e) {
    //     return _eventListeners(event, jsObject: e);
    //   }).catchError((e) {});
    // }
  }

  void _removeTronEvent(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    _tronEventListeners[event]?.remove(listener);
  }

  void _signMessageV2(String message, String? privateKey) {}

  void _signTransaction(JSAny message, String? privateKey) {}

  JSPromise<JSAny?> _onTronRequest(TronRequestParams params) {
    throw Exception("handle nashodiyo hanow :D");
  }
}
