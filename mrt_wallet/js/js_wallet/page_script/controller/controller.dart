part of '../scripts.dart';

typedef POSTPAGEMESSAGE = void Function(PageMessage message);

abstract class JSBasePageController {
  SynchronizedLock? _lock = SynchronizedLock();
  Completer<void>? _wait = Completer();

  Future<void> _waitForActivation() async {
    return await _lock?.synchronized(() async {
      try {
        return await _wait?.future;
      } finally {
        _wait = null;
        _lock = null;
      }
    });
  }

  void postMessage(PageMessage message) {}
  late final EthereumPageController ethereumPageController =
      EthereumPageController(postMessage);
  late final TronPageController tronPageController =
      TronPageController(postMessage);
  late final SolanaPageController solanaPageController =
      SolanaPageController(postMessage);
  late final TonPageController tonPageController =
      TonPageController(postMessage);
  late final StellarPageController stellarPageController =
      StellarPageController(postMessage);
  late final SubstratePageController substratePageController =
      SubstratePageController(postMessage);
  late final AptosPageController aptosPageController =
      AptosPageController(postMessage);
  late final SuiPageController suiPageController =
      SuiPageController(postMessage);

  String? _walletId;

  void _initControllers() {
    try {
      ethereumPageController._initController();
      tronPageController._initController();
      solanaPageController._initController();
      tonPageController._initController();
      stellarPageController._initController();
      substratePageController._initController();
      aptosPageController._initController();
      suiPageController._initController();
    } catch (e) {
      jsConsole.error("Initializing wallet failed: $e");
    }
  }

  void disable(JSWalletError err) {
    if (err.message != null) {
      jsConsole.error(err.message);
    }
    ethereumPageController._disable();
    tronPageController._disable();
    solanaPageController._disable();
    tonPageController._disable();
    stellarPageController._disable();
    substratePageController._disable();
    aptosPageController._disable();
    suiPageController._disable();
    _wait?.completeError(err);
  }

  void initClients(String clientId);

  void handleWalletMessage(WalletMessage walletResponse) {
    try {
      if (walletResponse.data.messageType == JSWalletMessageType.response) {
        PageNetworkController._completeRequest(
            requestId: walletResponse.requestId,
            walletResponse: walletResponse.data as WalletMessageResponse);
        return;
      }
      final event = walletResponse.data as WalletMessageEvent;
      switch (walletResponse.clientType) {
        case JSClientType.ethereum:
          ethereumPageController.onEvent(event);
          break;
        case JSClientType.tron:
          tronPageController.onEvent(event);
          break;
        case JSClientType.solana:
          solanaPageController.onEvent(event);
          break;
        case JSClientType.ton:
          tonPageController.onEvent(event);
          break;
        case JSClientType.stellar:
          stellarPageController.onEvent(event);
          break;
        case JSClientType.substrate:
          substratePageController.onEvent(event);
          break;
        case JSClientType.aptos:
          aptosPageController.onEvent(event);
          break;
        case JSClientType.sui:
          suiPageController.onEvent(event);
          break;
        default:
          break;
      }
    } catch (e) {
      WalletLogging.error("got error $e");
      rethrow;
    }
  }
}

class JSPageController extends JSBasePageController {
  JSPageController._();
  @override
  void postMessage(PageMessage message) async {
    await _waitForActivation();
    final event = CustomEvent.create(type: _walletId, detail: message);
    jsWindow.dispatchEvent(event);
  }

  factory JSPageController.setup() {
    final client = JSPageController._();
    client._initControllers();
    return client;
  }

  void _onWalletEvent(CustomEvent response) {
    final WalletMessage walletResponse = response.detail as WalletMessage;
    handleWalletMessage(walletResponse);
  }

  @override
  void initClients(String clientId) {
    if (_walletId != null) return;
    _walletId = JsUtils.toWalletId(clientId);
    jsWindow.addEventListener(
        JsUtils.toEthereumClientId(clientId), _onWalletEvent.toJS);
    _wait?.complete();
  }
}

class JSWithWorkerPageController extends JSBasePageController {
  Worker? _worker;
  JSWithWorkerPageController._();
  @override
  void postMessage(PageMessage message) async {
    await _waitForActivation();
    _worker
        ?.postMessage(JSWorkerEvent(data: message, type: JSWorkerType.client));
  }

  factory JSWithWorkerPageController.setup() {
    final client = JSWithWorkerPageController._();
    client._initControllers();
    return client;
  }

  @override
  void initClients(String clientId, {Worker? worker}) {
    if (_worker != null) return;
    _worker = worker;
    _wait?.complete();
  }

  void onWalletEvent(WalletMessage response) {
    handleWalletMessage(response);
  }
}
