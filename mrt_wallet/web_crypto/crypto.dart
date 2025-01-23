import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/crypto/isolate/controller/message_controller.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models.dart';
import 'dart:js_interop';

@JS("postMessage")
external void postMessage(JSAny data);

@JS()
external set mrtJsHandler(JSFunction handler);

@JS()
external set mrtWalletActivation(JSFunction? handler);

void _send(String message) {
  _cryptoHandler.sentResult(message).then((e) {
    postMessage(BytesUtils.toHexString(e.serialize()).toJS);
  });
}

late _WebIsolateInitialData _cryptoHandler;
bool _init = false;

String _readKey() {
  if (_init) return "";
  try {
    _init = true;
    final key = QuickCrypto.generateRandom(32);
    _cryptoHandler = _WebIsolateInitialData(key: key);

    return BytesUtils.toHexString(key);
  } finally {
    mrtWalletActivation = null;
  }
}

void main(List<String> args) {
  mrtJsHandler = _send.toJS;
  mrtWalletActivation = _readKey.toJS;
}

class _WebIsolateInitialData {
  late final EncryptedIsolateMessageController crypto =
      EncryptedIsolateMessageController((message, id) {
    final encrypted =
        _toEncryptedMessage(request: message, encrypted: true, requestId: id);
    postMessage(BytesUtils.toHexString(encrypted.serialize()).toJS);
  });
  final ChaCha20Poly1305 chacha;
  _WebIsolateInitialData({required List<int> key})
      : chacha = ChaCha20Poly1305(key);
  Future<(CborMessageArgs, bool, int)> _getResult(List<int> message) async {
    int? id;
    bool? encrypted;
    try {
      final msg = WorkerMessage.deserialize(bytes: message);
      id = msg.id;
      encrypted = msg.type.isEncrypted;
      List<int> messageBytes = msg.message;
      if (encrypted) {
        final encryptedMessage = msg.cast<WorkerEncryptedMessage>();
        messageBytes =
            chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message)!;
      }
      final args = CborMessageArgs.deserialize(messageBytes);
      List<int>? encryptedPart;
      if (!encrypted) {
        final nonEncryptedMessage = msg.cast<WorkerNoneEncryptedMessage>();
        if (nonEncryptedMessage.encryptedPart != null) {
          encryptedPart = chacha.decrypt(
              nonEncryptedMessage.encryptedPart!.nonce,
              nonEncryptedMessage.encryptedPart!.message)!;
        }
      }

      final response = await crypto.handleMessage(
          args: args, id: id, encryptedPart: encryptedPart);
      return (response, encrypted, id);
    } catch (_) {
      return (
        EncryptedIsolateMessageController.verificationFailed,
        encrypted ?? true,
        id ?? -1
      );
    }
  }

  Future<WorkerMessage> sentResult(String message) async {
    final List<int>? messagesBytes = BytesUtils.tryFromHexString(message);
    CborMessageArgs? result;
    bool isEncrypted = true;
    int id = -1;
    if (messagesBytes == null) {
      result = EncryptedIsolateMessageController.verificationFailed;
    } else {
      final r = await _getResult(messagesBytes);
      result = r.$1;
      isEncrypted = r.$2;
      id = r.$3;
    }
    final encrypted = _toEncryptedMessage(
        request: result, requestId: id, encrypted: isEncrypted);
    return encrypted;
  }

  WorkerMessage _toEncryptedMessage(
      {required CborMessageArgs request,
      required bool encrypted,
      required int requestId}) {
    if (encrypted) {
      final nonce = QuickCrypto.generateRandom(16);
      final enc = chacha.encrypt(nonce, request.toCbor().encode());

      return WorkerEncryptedMessage(message: enc, nonce: nonce, id: requestId);
    }
    return WorkerNoneEncryptedMessage(
        message: request.toCbor().encode(), id: requestId);
  }
}
