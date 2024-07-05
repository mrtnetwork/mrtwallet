import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wroker/models/bytes.dart';
import 'message_type.dart';

class WorkerMessageRequest with CborSerializable {
  final WorkerMessageBytes message;
  final int id;
  const WorkerMessageRequest({required this.message, required this.id});
  factory WorkerMessageRequest.deserialize(List<int> bytes) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, null, WorkerMessageConst.workerMessagRequest);
    final int id = cbor.elementAt(0);
    final List<int> msgBytes = cbor.elementAt(1);
    return WorkerMessageRequest(
        message: WorkerMessageBytes.deserialize(msgBytes), id: id);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborIntValue(id), CborBytesValue(message.toCbor().encode())]),
        WorkerMessageConst.workerMessagRequest);
  }
}

class WorkerMessageBytes with CborSerializable {
  final ArgsBytes args;
  const WorkerMessageBytes({required this.args, required this.message});

  final CryptoMessageType message;
  factory WorkerMessageBytes.deserialize(List<int> bytes) {
    final CborTagValue tag = CborSerializable.toTagValue(bytes);
    final CryptoMessageType msg = CryptoMessageType.fromTag(tag.tags);
    final CborBytesValue argsBytes = tag.valueAs();
    final args = ArgsBytes.deserialize(argsBytes.value);
    return WorkerMessageBytes(args: args, message: msg);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborBytesValue(args.toCbor().encode()), message.tag);
  }
}
