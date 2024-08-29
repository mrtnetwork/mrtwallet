part of 'core/wallet.dart';

enum JSWebviewTraget {
  android,
  macos;

  static JSWebviewTraget? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

class JSWebviewWallet extends JSWalletHandler {
  @override
  final String clientId;
  @override
  ChainsHandler _chain;
  final JSWebviewTraget target;

  JSWebviewWallet._({
    required ChaCha20Poly1305 crypto,
    required ChainsHandler chain,
    required this.clientId,
    required this.target,
  })  : _chain = chain,
        super._(crypto);
  factory JSWebviewWallet.initialize(
      {required WalletEvent request,
      required String clientId,
      required JSWebviewTraget target}) {
    final chacha =
        ChaCha20Poly1305(QuickCrypto.sha256Hash(StringUtils.encode(clientId)));
    final data = List<int>.from(request.data);
    final encryptedMessage = Web3EncryptedMessage.deserialize(bytes: data);
    final decode =
        chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
    final message = Web3ChainMessage.deserialize(bytes: decode);
    final handler = JSWebviewWallet._(
        crypto: ChaCha20Poly1305(message.authenticated.token),
        chain: ChainsHandler.deserialize(bytes: message.message),
        clientId: clientId,
        target: target);
    JSPageController.setup(clientId);
    mrt.onMrtMessage = handler._onResponse.toJS;
    handler._listenOnClients();
    handler._updateAuthenticated(message.authenticated, network: null);
    return handler;
  }

  @override
  Future<void> _sendMessageToWallet(
      {required Web3MessageCore message, required String requestId}) async {
    final encryptedMessage = _encryptMessage(message);
    if (target == JSWebviewTraget.macos) {
      jsWindow.webkit.messageHandlers.mrt.postMessage({
        "id": clientId,
        "requestId": requestId,
        "data": encryptedMessage.toCbor().toCborHex(),
        "type": WalletEventTypes.message.name
      }.jsify());
      return;
    }
    mrt.onMrtJsRequest(clientId, encryptedMessage.toCbor().toCborHex(),
        requestId, WalletEventTypes.message.name);
  }
}
