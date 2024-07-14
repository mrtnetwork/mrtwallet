import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wroker/messages/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/messages/types/message_type.dart';

// class WorkerMessageRequest with CborSerializable {
//   final WorkerMessageBytes message;
//   const WorkerMessageRequest({required this.message});
//   factory WorkerMessageRequest.deserialize(List<int> bytes) {
//     final CborListValue cbor = CborSerializable.decodeCborTags(
//         bytes, null, WorkerMessageConst.workerMessagRequest);
//     final List<int> msgBytes = cbor.elementAt(1);
//     return WorkerMessageRequest(
//         message: WorkerMessageBytes.deserialize(msgBytes));
//   }

//   @override
//   CborTagValue toCbor() {
//     return CborTagValue(
//         CborListValue.fixedLength([CborBytesValue(message.toCbor().encode())]),
//         WorkerMessageConst.workerMessagRequest);
//   }
// }

class WorkerMessageBytes with CborSerializable {
  final MessageArgs args;
  const WorkerMessageBytes({required this.args, required this.message});

  final CryptoMessageType message;
  factory WorkerMessageBytes.deserialize(List<int> bytes) {
    final CborTagValue tag = CborSerializable.toTagValue(bytes);
    final CryptoMessageType msg = CryptoMessageType.fromTag(tag.tags);
    final CborBytesValue argsBytes = tag.valueAs();
    final args = MessageArgs.deserialize(argsBytes.value);
    return WorkerMessageBytes(args: args, message: msg);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborBytesValue(args.toCbor().encode()), message.tag);
  }
}
