part of 'core/wallet.dart';

enum JSWebviewTraget {
  android,
  macos;

  bool get isMacos => this == macos;
  static JSWebviewTraget? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

class JSWebviewWallet extends JSWalletHandler {
  @override
  final String clientId;

  final JSWebviewTraget target;
  final bool isWorker;

  Web3APPData? _initializeAuthenticated;

  void initClients() {
    final auth = _initializeAuthenticated;
    if (auth == null) return;
    _initializeAuthenticated = null;
    _updateAuthenticated(auth);
  }

  void _inWorkerResponse(MessageEvent jsRequest) {
    final event = jsRequest.data as JSWorkerEvent;
    switch (event.eventType) {
      case JSWorkerType.wallet:
        _onResponse((event.data as JSWalletEvent).toEvent());
        break;
      case JSWorkerType.client:
        handleClientMessage(event.data as PageMessage);
        break;
      default:
        break;
    }
  }

  bool _onMainResponse(JSWalletEvent jsEvnt) {
    final event = jsEvnt.toEvent();
    return _onResponse(event);
  }

  @override
  void _listenOnClients({bool isWorker = false}) {
    if (!isWorker) return super._listenOnClients();
  }

  JSWebviewWallet._({
    required ChaCha20Poly1305 crypto,
    required this.clientId,
    required this.target,
    required this.isWorker,
    Web3APPData? initializeAuthenticated,
  })  : _initializeAuthenticated = initializeAuthenticated,
        super._(crypto);
  factory JSWebviewWallet.initialize(
      {required WalletEvent request,
      required String clientId,
      required JSWebviewTraget target,
      bool isWorker = true}) {
    final chacha =
        ChaCha20Poly1305(QuickCrypto.sha256Hash(StringUtils.encode(clientId)));
    final data = List<int>.from(request.data);
    final encryptedMessage = Web3EncryptedMessage.deserialize(bytes: data);
    final decode =
        chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
    final message = Web3ChainMessage.deserialize(bytes: decode);
    final handler = JSWebviewWallet._(
        crypto: ChaCha20Poly1305(message.authenticated.token),
        clientId: clientId,
        target: target,
        isWorker: isWorker,
        initializeAuthenticated: message.authenticated);
    if (isWorker) {
      onMessage = handler._inWorkerResponse.toJS;
    } else {
      mrt.onMrtMessage = handler._onMainResponse.toJS;
    }

    handler._listenOnClients(isWorker: isWorker);
    return handler;
  }

  @override
  void _sendMessageToClient(WalletMessage response) {
    if (!isWorker) return super._sendMessageToClient(response);
    final event = JSWorkerEvent(type: JSWorkerType.client, data: response);
    postMessage(event);
  }

  @override
  Future<void> _sendMessageToWallet(
      {required Web3MessageCore message, required String requestId}) async {
    final encryptedMessage = _encryptMessage(message).toCbor().toCborHex();
    if (isWorker) {
      final event = JSWorkerWalletData(
          clientId: clientId,
          requestId: requestId,
          data: encryptedMessage,
          type: WalletEventTypes.message.name);
      postMessage(JSWorkerEvent(data: event, type: JSWorkerType.wallet));
      return;
    }
    if (target == JSWebviewTraget.macos) {
      jsWindow.webkit.messageHandlers.mrt.postMessage({
        "id": clientId,
        "requestId": requestId,
        "data": encryptedMessage,
        "type": WalletEventTypes.message.name
      }.jsify());
      return;
    }
    mrt.onMrtJsRequest(
        clientId, encryptedMessage, requestId, WalletEventTypes.message.name);
  }

  @override
  JSWalletMode get mode => JSWalletMode.webview;
}
