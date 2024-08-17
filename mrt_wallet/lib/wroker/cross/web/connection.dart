import 'dart:js_interop';
import 'package:blockchain_utils/crypto/crypto/chacha20poly1305/chacha20poly1305.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/wroker/crypto/crypto.dart';
import 'package:mrt_wallet/wroker/requets/messages.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart' as web;

class WebConnectionInfo {
  final ChaCha20Poly1305 chacha;
  final web.Worker worker;
  WebConnectionInfo({
    required List<int> key,
    required this.worker,
  }) : chacha = ChaCha20Poly1305(key) {
    setResponse();
  }

  final Map<int, WorkerMessageCompleter> _requests = {};
  void setResponse() {
    worker.addEventListener(
        "message",
        (JSAny e) {
          final String message = (e.dartify() as Map)["data"];
          final result = getResult(message);
          _requests[result.id]?.complete(result);
        }.toJS);
  }

  bool get isActive => true;

  String _toEncryptedMessage(WorkerRequestMessage request, int id) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, request.toCbor().encode());
    final encryptMessage =
        WorkerEncryptedMessage(message: enc, nonce: nonce, id: id);
    return BytesUtils.toHexString(encryptMessage.toCbor().encode());
  }

  Future<MessageArgs> sentRequest(
      WorkerRequestMessage request, int requestId) async {
    final id = WorkerMessageCompleter(requestId);
    _requests[id.id] = id;
    final encryptMessage = _toEncryptedMessage(request, requestId);
    worker.postMessage(encryptMessage.toJS);
    final r = await id.getResult();
    return r;
  }

  WorkerResponseMessage getResult(dynamic message) {
    int? id;
    try {
      final encryptMessageBytes = BytesUtils.fromHexString(message);
      final encryptedMessage =
          WorkerEncryptedMessage.deserialize(encryptMessageBytes);
      final decode =
          chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      id = encryptedMessage.id;
      final response = WorkerResponseMessage.deserialize(decode!);
      return response;
    } catch (e) {
      return WorkerResponseMessage(
          args: WalletCrypto.verificationFailed, id: id ?? -1);
    }
  }
}
