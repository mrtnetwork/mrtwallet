import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

enum WorkerMessageType {
  encrypted(WorkerMessageConst.encryptedMessage),
  nonEncrypted(WorkerMessageConst.noneEncryptedMessage),
  cbor(WorkerMessageConst.cborMessage);

  final List<int> tag;
  const WorkerMessageType(this.tag);
  static WorkerMessageType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  static WorkerMessageType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }

  bool get isEncrypted => this == encrypted;
}

abstract class WorkerMessage<MESSAGE, SERIALIZE> {
  final WorkerMessageType type;
  abstract final MESSAGE message;
  final int id;
  final int? totalPart;
  final int? currentPart;

  SERIALIZE serialize();

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "id": id,
      "totalPart": totalPart,
      "currentPart": currentPart
    };
  }

  WorkerMessage._(
      {required this.type, required this.id, this.totalPart, this.currentPart});
  WorkerMessage.fromJson(Map<String, dynamic> json)
      : type = WorkerMessageType.fromName(json["type"]),
        id = json["id"],
        totalPart = json["totalPart"],
        currentPart = json["currentPart"];
  static WorkerMessage<List<int>, List<int>> deserialize(
      {List<int>? bytes, CborObject? cbor, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: cbor, hex: hex);
    final type = WorkerMessageType.fromTag(decode.tags);
    return switch (type) {
      WorkerMessageType.encrypted =>
        WorkerEncryptedMessage.deserialize(object: decode)
            as WorkerMessage<List<int>, List<int>>,
      WorkerMessageType.nonEncrypted =>
        WorkerNoneEncryptedMessage.deserialize(object: decode)
            as WorkerMessage<List<int>, List<int>>,
      WorkerMessageType.cbor => throw UnimplementedError(),
    };
  }

  T cast<T extends WorkerMessage>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", toString()]);
    }
    return this as T;
  }
}

class WorkerNoneEncryptedMessage extends WorkerMessage<List<int>, List<int>>
    with CborSerializable {
  @override
  final List<int> message;
  final WorkerEncryptedMessage? encryptedPart;
  // bool get isEncrypted =>
  //     args.type == ArgsType.wallet || args.type == ArgsType.crypto;
  WorkerNoneEncryptedMessage({
    required this.message,
    required super.id,
    super.currentPart,
    this.encryptedPart,
    super.totalPart,
  }) : super._(type: WorkerMessageType.nonEncrypted);
  factory WorkerNoneEncryptedMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WorkerMessageType.nonEncrypted.tag);
    return WorkerNoneEncryptedMessage(
        message: cbor.elementAt(0),
        id: cbor.elementAt(1),
        encryptedPart: cbor.elemetMybeAs<WorkerEncryptedMessage, CborObject>(
          2,
          (p0) => WorkerEncryptedMessage.deserialize(object: p0),
        ));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          CborIntValue(id),
          encryptedPart?.toCbor()
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "message": BytesUtils.toHexString(message),
    };
  }

  @override
  List<int> serialize() {
    return toCbor().encode();
  }
}

class WorkerEncryptedMessage extends WorkerMessage<List<int>, List<int>>
    with CborSerializable {
  final List<int> nonce;
  @override
  final List<int> message;
  WorkerEncryptedMessage.fromJson(super.json)
      : nonce = BytesUtils.fromHexString(json["nonce"]),
        message = BytesUtils.fromHexString(json["message"]),
        super.fromJson();
  WorkerEncryptedMessage({
    required List<int> message,
    required List<int> nonce,
    required super.id,
    super.currentPart,
    super.totalPart,
  })  : nonce = nonce.asImmutableBytes,
        message = message.asImmutableBytes,
        super._(type: WorkerMessageType.encrypted);
  factory WorkerEncryptedMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WorkerMessageType.encrypted.tag);
    return WorkerEncryptedMessage(
        nonce: cbor.elementAt(0),
        message: cbor.elementAt(1),
        id: cbor.elementAt(2));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "nonce": BytesUtils.toHexString(nonce),
      "message": BytesUtils.toHexString(message),
    };
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(nonce), CborBytesValue(message), CborIntValue(id)]),
        type.tag);
  }

  @override
  List<int> serialize() {
    return toCbor().encode();
  }
}

class WorkerCborMessage extends WorkerMessage<MessageArgsCbor, List<int>>
    with CborSerializable {
  @override
  final MessageArgsCbor message;
  final WorkerEncryptedMessage? encryptedPart;
  // bool get isEncrypted =>
  //     args.type == ArgsType.wallet || args.type == ArgsType.crypto;
  WorkerCborMessage({
    required this.message,
    required super.id,
    super.currentPart,
    this.encryptedPart,
    super.totalPart,
  }) : super._(type: WorkerMessageType.cbor);
  factory WorkerCborMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WorkerMessageType.cbor.tag);
    return WorkerCborMessage(
        message: MessageArgsCbor.deserialize(object: cbor.getCborTag(0)),
        id: cbor.elementAt(1),
        encryptedPart: cbor.elemetMybeAs<WorkerEncryptedMessage, CborObject>(
            2, (p0) => WorkerEncryptedMessage.deserialize(object: p0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [message.toCbor(), CborIntValue(id), encryptedPart?.toCbor()]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()};
  }

  @override
  List<int> serialize() {
    return toCbor().encode();
  }
}
