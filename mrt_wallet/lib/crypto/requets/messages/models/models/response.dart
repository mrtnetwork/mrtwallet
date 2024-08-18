import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WorkerResponseMessage with CborSerializable {
  final MessageArgs args;
  final int id;
  const WorkerResponseMessage({required this.args, required this.id});
  factory WorkerResponseMessage.deserialize(List<int> bytes) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, null, WorkerMessageConst.workerMessagResponse);
    final int id = cbor.elementAt(0);
    final List<int> msgBytes = cbor.elementAt(1);
    return WorkerResponseMessage(
        args: MessageArgs.deserialize(msgBytes), id: id);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborIntValue(id), CborBytesValue(args.toCbor().encode())]),
        WorkerMessageConst.workerMessagResponse);
  }
}
