import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wroker/keys/keys.dart';
import 'package:mrt_wallet/wroker/messages/types/message_type.dart';
import '../argruments/argruments.dart';

class WorkerMessageResponse with CborSerializable {
  final MessageArgs args;
  final int id;
  const WorkerMessageResponse({required this.args, required this.id});
  factory WorkerMessageResponse.deserialize(List<int> bytes) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, null, WorkerMessageConst.workerMessagResponse);
    final int id = cbor.elementAt(0);
    final List<int> msgBytes = cbor.elementAt(1);
    return WorkerMessageResponse(
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

class GlobalSignResponse with CborSerializable {
  final List<int> signature;
  final AddressDerivationIndex index;
  final CryptoPublicKeyData signerPubKey;
  GlobalSignResponse({
    required List<int> signature,
    required this.index,
    required this.signerPubKey,
  }) : signature = BytesUtils.toBytes(signature);

  factory GlobalSignResponse.deserialize(List<int> bytes) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, tags: CryptoKeyConst.globalSignature);
    final index =
        AddressDerivationIndex.fromCborBytesOrObject(obj: values.getCborTag(0));
    final List<int> signature = values.elementAt(1);
    return GlobalSignResponse(
        signature: signature,
        index: index,
        signerPubKey:
            PublicKeyData.fromCborBytesOrObject(obj: values.getCborTag(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [index.toCbor(), signature, signerPubKey.toCbor()]),
        CryptoKeyConst.globalSignature);
  }
}
