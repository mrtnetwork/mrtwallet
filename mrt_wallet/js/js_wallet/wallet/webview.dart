part of 'core/wallet.dart';

class JSWebviewWallet extends JSWalletHandler {
  @override
  final String clientId;
  @override
  ChainsHandler _chain;

  JSWebviewWallet._({
    required ChaCha20Poly1305 crypto,
    required ChainsHandler chain,
    required this.clientId,
  })  : _chain = chain,
        super._(crypto);
  factory JSWebviewWallet.initialize(
      {required WalletEvent request, required String clientId}) {
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
        clientId: clientId);
    EthereumJsController.setup(clientId);
    mrt.onMrtMessage = handler._onResponse.toJS;
    handler._listenOnClients();
    handler._updateAuthenticated(message.authenticated, initChain: true);
    return handler;
  }

  @override
  Future<void> _sendMessageToWallet(
      {required Web3MessageCore message, required String requestId}) async {
    final encryptedMessage = _encryptMessage(message);
    mrt.onMrtJsRequest(clientId, encryptedMessage.toCbor().toCborHex(),
        requestId, WalletEventTypes.message.name);
  }
}
