import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/models/message_type.dart';
import 'bytes.dart';

class WorkerMessageResponse with CborSerializable {
  final ArgsBytes args;
  final int id;
  const WorkerMessageResponse({required this.args, required this.id});
  factory WorkerMessageResponse.deserialize(List<int> bytes) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, null, WorkerMessageConst.workerMessagResponse);
    final int id = cbor.elementAt(0);
    final List<int> msgBytes = cbor.elementAt(1);
    return WorkerMessageResponse(args: ArgsBytes.deserialize(msgBytes), id: id);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborIntValue(id), CborBytesValue(args.toCbor().encode())]),
        WorkerMessageConst.workerMessagResponse);
  }
}

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
