import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WorkerEncryptedMessage with CborSerializable {
  final List<int> message;
  final List<int> nonce;
  final int id;
  WorkerEncryptedMessage(
      {required List<int> message, required List<int> nonce, required this.id})
      : nonce = BytesUtils.toBytes(nonce, unmodifiable: true),
        message = BytesUtils.toBytes(message, unmodifiable: true);
  factory WorkerEncryptedMessage.deserialize(List<int> bytes) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, null, WorkerMessageConst.encryptedMessage);
    return WorkerEncryptedMessage(
        nonce: cbor.elementAt(0),
        message: cbor.elementAt(1),
        id: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(nonce), CborBytesValue(message), CborIntValue(id)]),
        WorkerMessageConst.encryptedMessage);
  }
}
