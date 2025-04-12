part of '../scripts.dart';

class JSPageWalletStandardController {
  final PageRequestController _requestController;
  JSPageWalletStandardController(this._requestController);
  final _walletStandard = JSWalletStandard(JSObject());
  final _feature = JSWalletStandardFeature(JSObject());
  final List<JSFunction> _listeneers = [];
  JSFunction? _onEvents(JSString type, JSFunction listener) {
    final eventType = JSEventType.fromName(type.toDart);
    if (eventType != JSEventType.change) return null;
    if (eventType != null) {
      _listeneers.add(listener);
    }
    final toWalletRequest = PageMessage.event(
        data: PageMessageEvent.build(event: JSEventType.change));
    _requestController.postMessage(toWalletRequest);
    void remove() {
      _listeneers.remove(listener);
    }

    return remove.toJS;
  }

  void _emit(JSAny? message) {
    final clone = [..._listeneers];
    for (final i in clone) {
      i.callAsFunction(i, message);
    }
  }

  void _onGlobalEventEvent(WalletMessageEvent message) {
    final event = message.data as JSWalletStandardChange;
    if (event.accounts != null) {
      _walletStandard.accounts = event.accounts!;
    }
    if (event.chains != null) {
      _walletStandard.chains = event.chains!;
    }
    _emit(JSWalletStandardEvent(event).toProxy());
  }

  JSPromise<JSWalletStandardConnect> _connect(
      [JSWalletStandardConnectParams? silent]) {
    Future<JSWalletStandardConnect> connect() async {
      bool s = false;
      if (silent.isDefinedAndNotNull) {
        s = silent!.silent ?? false;
      }
      final response = await _requestController
          .waitForSuccessResponse<JSWalletStandardConnect>(
              method: JSWalletStandardConst.standardConnectName,
              params: [s.toJS].toJS);
      _walletStandard.accounts = response.accounts;
      return response;
    }

    return connect().toPromise;
  }

  void _initController() {
    _feature.events = JSWalletStandardEventsFeature.setup(on: _onEvents.toJS);
    _feature.connect =
        SolanaWalletAdapterStandardConnectFeature.setup(connect: _connect.toJS);
    _walletStandard.features = _feature;
    _walletStandard.name = JSWalletConstant.name;
    _walletStandard.version = SolanaJSConstant.version;
    _walletStandard.icon = JSWalletConstant.mrtPngBase64;
    _walletStandard.accounts = <JSWalletStandardAccount>[].toJS;
    final event = CustomEvent(
        SolanaJSConstant.walletStandardRegisterEvent,
        EventInit(
            bubbles: false,
            cancelable: false,
            detail: (StandardWalletAdapterRegisterEvent event) {
              event.register(_walletStandard);
            }.toJS));
    jsWindow.addEventListener(
        SolanaJSConstant.walletStandardAppReadyEvent,
        (JSAny _) {
          jsWindow.dispatchEvent(event);
        }.toJS);
    jsWindow.dispatchEvent(event);
  }
}
