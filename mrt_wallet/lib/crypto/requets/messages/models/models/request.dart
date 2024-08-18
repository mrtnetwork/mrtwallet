import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class WorkerRequestMessage with CborSerializable {
  final MessageArgs args;
  const WorkerRequestMessage({required this.args, required this.message});

  final CryptoMessageType message;
  factory WorkerRequestMessage.deserialize(List<int> bytes) {
    final CborTagValue tag = CborSerializable.toTagValue(bytes);
    final CryptoMessageType msg = CryptoMessageType.fromTag(tag.tags);
    final CborBytesValue argsBytes = tag.valueAs();
    final args = MessageArgs.deserialize(argsBytes.value);
    return WorkerRequestMessage(args: args, message: msg);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborBytesValue(args.toCbor().encode()), message.tag);
  }
}
