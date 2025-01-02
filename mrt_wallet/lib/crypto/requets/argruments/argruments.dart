import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/requests/read_master_key.dart';

class _MessageArgsTags {
  static const List<int> twoBytes = [1, 2];
  static const List<int> oneBytes = [1, 1];
  static const List<int> streamId = [1, 4];
  static const List<int> streamArgs = [1, 5];
  static const List<int> threeBytes = [1, 3];
  static const List<int> exception = [0, 0];
  static const List<int> message = [0, 1];
  static const List<int> network = [2, 0];
  static const List<int> nonEncrypted = [2, 1];
  static const List<int> wallet = [3, 0];
  static const List<int> stream = [2, 3];
  static const List<int> cbor = [2, 4];
}

enum ArgsType {
  streamId(_MessageArgsTags.streamId),
  message(_MessageArgsTags.message),
  streamArgs(_MessageArgsTags.streamArgs),
  oneArg(_MessageArgsTags.oneBytes),
  twoArgs(_MessageArgsTags.twoBytes),
  threeArgs(_MessageArgsTags.threeBytes),
  exception(_MessageArgsTags.exception),
  crypto(_MessageArgsTags.network),
  nonEncrypted(_MessageArgsTags.nonEncrypted),
  streamRequest(_MessageArgsTags.stream),
  wallet(_MessageArgsTags.wallet),
  cbor(_MessageArgsTags.cbor);

  static const int tagLength = 2;

  bool get isEncrypted => this == ArgsType.wallet || this == ArgsType.crypto;

  final List<int> tag;
  const ArgsType(this.tag);
  static ArgsType fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag?.sublist(0, tagLength)),
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "invalid args type tag."));
  }
}

// enum IsolateMessageArgsMode { cbor, json }

// abstract class IsolateMessageArgs {
//   abstract final ArgsType type;
//   abstract final IsolateMessageArgsMode mode;
//   const IsolateMessageArgs();
// }

// abstract class JsonMessageArgs extends IsolateMessageArgs {
//   abstract final ArgsType type;
//   Map<String, dynamic> toJson();
//   static T fromJson<T extends JsonMessageArgs>(Map<String, dynamic> json) {
//     throw UnimplementedError();
//   }

//   IsolateMessageArgsMode get mode => IsolateMessageArgsMode.json;
// }

abstract class CborMessageArgs with CborSerializable {
  const CborMessageArgs();
  abstract final ArgsType type;
  static T deserialize<T extends CborMessageArgs>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final type = ArgsType.fromTag(cbor.tags);
    CborMessageArgs args;
    switch (type) {
      case ArgsType.oneArg:
        args = MessageArgsOneBytes.deserialize(object: cbor);
        break;
      case ArgsType.streamId:
        args = MessageArgsStreamId.deserialize(object: cbor);
        break;
      case ArgsType.twoArgs:
        args = MessageArgsTwoBytes.deserialize(object: cbor);
        break;
      case ArgsType.threeArgs:
        args = MessageArgsThreeBytes.deserialize(object: cbor);
        break;
      case ArgsType.exception:
        args = MessageArgsException.deserialize(object: cbor);
        break;
      case ArgsType.crypto:
        args = CryptoRequest.deserialize(object: cbor);
        break;
      case ArgsType.nonEncrypted:
        args = NoneEncryptedCryptoRequest.deserialize(object: cbor);
        break;
      case ArgsType.wallet:
        args = WalletArgs.deserialize(object: cbor);
        break;
      case ArgsType.streamRequest:
        args = IsolateStreamRequest.deserialize(object: cbor);
        break;
      case ArgsType.streamArgs:
        args = MessageArgsStream.deserialize(object: cbor);
        break;
      case ArgsType.message:
        args = MessageArgsMessage.deserialize(object: cbor);
        break;
      case ArgsType.cbor:
        args = MessageArgsCbor.deserialize(object: cbor);
        break;
    }
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return args;
  }
}

// abstract class EncodableMessageArgs
//     implements CborMessageArgs, JsonMessageArgs {
//   abstract final ArgsType type;
//   const EncodableMessageArgs();
//   T cast<T extends IsolateMessageArgs>() {
//     return this as T;
//   }
// }

abstract class RequestableMessage extends CborMessageArgs {
  const RequestableMessage();
}

abstract class MessageArgsRequestable extends RequestableMessage {
  const MessageArgsRequestable();
}

abstract class WalletArgsRequestable<ARGS extends ArgsCompleter>
    extends RequestableMessage {
  abstract final ARGS args;
  const WalletArgsRequestable();
}

abstract class StreamArgsRequestable<ARGS extends ArgsCompleter>
    extends RequestableMessage {
  const StreamArgsRequestable();
}

class MessageArgsTwoBytes extends CborMessageArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  MessageArgsTwoBytes({required List<int> keyOne, required List<int> keyTwo})
      : keyOne = keyOne.asImmutableBytes,
        keyTwo = keyTwo.asImmutableBytes;
  factory MessageArgsTwoBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.twoArgs.tag);
    return MessageArgsTwoBytes(
        keyOne: values.elementAt(0), keyTwo: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(keyOne), CborBytesValue(keyTwo)]),
        ArgsType.twoArgs.tag);
  }

  @override
  ArgsType get type => ArgsType.twoArgs;
}

class MessageArgsOneBytes extends CborMessageArgs {
  final List<int> keyOne;
  MessageArgsOneBytes({required List<int> keyOne})
      : keyOne = keyOne.asImmutableBytes;
  factory MessageArgsOneBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.oneArg.tag);
    return MessageArgsOneBytes(keyOne: values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([CborBytesValue(keyOne)]),
        ArgsType.oneArg.tag);
  }

  @override
  ArgsType get type => ArgsType.oneArg;
}

class MessageArgsStreamId extends CborMessageArgs {
  final String streamId;
  MessageArgsStreamId(this.streamId);
  factory MessageArgsStreamId.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.streamId.tag);
    return MessageArgsStreamId(values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([streamId]), ArgsType.streamId.tag);
  }

  @override
  ArgsType get type => ArgsType.streamId;
}

class MessageArgsThreeBytes extends CborMessageArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  final List<int> keyThree;
  MessageArgsThreeBytes(
      {required List<int> keyOne,
      required List<int> keyTwo,
      required List<int> keyThree})
      : keyOne = keyOne.asImmutableBytes,
        keyTwo = keyTwo.asImmutableBytes,
        keyThree = keyThree.asImmutableBytes;
  factory MessageArgsThreeBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.threeArgs.tag);
    return MessageArgsThreeBytes(
        keyOne: values.elementAt(0),
        keyTwo: values.elementAt(1),
        keyThree: values.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(keyOne),
          CborBytesValue(keyTwo),
          CborBytesValue(keyThree)
        ]),
        ArgsType.threeArgs.tag);
  }

  @override
  ArgsType get type => ArgsType.threeArgs;
}

enum MessageArgsStreamMethod {
  data(0),
  close(1),
  done(2);

  final int value;
  const MessageArgsStreamMethod(this.value);
  static MessageArgsStreamMethod fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: "stream method not found."));
  }
}

class MessageArgsStream extends MessageArgsRequestable {
  final List<int>? data;
  final String streamId;
  final MessageArgsStreamMethod method;
  MessageArgsStream._(
      {List<int>? data, required this.streamId, required this.method})
      : data = data?.asImmutableBytes;
  factory MessageArgsStream.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.streamArgs.tag);
    return MessageArgsStream._(
        data: values.elementAt(0),
        streamId: values.elementAs(1),
        method: MessageArgsStreamMethod.fromValue(values.elementAs(2)));
  }
  factory MessageArgsStream(
      {required List<int> data, required String streamId}) {
    return MessageArgsStream._(
        data: data, method: MessageArgsStreamMethod.data, streamId: streamId);
  }
  factory MessageArgsStream.close(String streamId) {
    return MessageArgsStream._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }
  factory MessageArgsStream.done(String streamId) {
    return MessageArgsStream._(
        method: MessageArgsStreamMethod.close, streamId: streamId);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          data == null ? null : CborBytesValue(data!),
          streamId,
          method.value
        ]),
        type.tag);
  }

  @override
  ArgsType get type => ArgsType.streamArgs;
}

class MessageArgsException extends CborMessageArgs {
  final String message;
  const MessageArgsException(this.message);
  factory MessageArgsException.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.exception.tag);
    return MessageArgsException(StringUtils.decode(values.elementAt(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(StringUtils.encode(message))]),
        ArgsType.exception.tag);
  }

  @override
  ArgsType get type => ArgsType.exception;

  @override
  String toString() {
    return "MessageArgsException:$message";
  }
}

class MessageArgsMessage extends CborMessageArgs {
  final String? message;
  const MessageArgsMessage({this.message});
  factory MessageArgsMessage.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.message.tag);
    return MessageArgsMessage(message: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([message]), ArgsType.message.tag);
  }

  @override
  ArgsType get type => ArgsType.message;

  @override
  String toString() {
    return "MessageArgsMessage:$message";
  }
}

class MessageArgsCbor extends CborMessageArgs {
  final CborObject message;
  const MessageArgsCbor({required this.message});
  factory MessageArgsCbor.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.cbor.tag);
    return MessageArgsCbor(message: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([message]), ArgsType.cbor.tag);
  }

  @override
  ArgsType get type => ArgsType.cbor;

  @override
  String toString() {
    return "MessageArgsCbor:$message";
  }
}

abstract class ArgsCompleter {
  const ArgsCompleter();
}

abstract class CborArgsCompleter extends ArgsCompleter with CborSerializable {
  const CborArgsCompleter();
}

abstract class JsonArgsCompleter extends ArgsCompleter {
  const JsonArgsCompleter();
  Map<String, dynamic> toJson();
}

abstract class EncodableArgsCompleter
    implements CborArgsCompleter, JsonArgsCompleter {
  const EncodableArgsCompleter();
}

abstract class StreamArgsCompleter<T, A extends CborMessageArgs, S>
    extends EncodableArgsCompleter implements StreamArgsRequestable {
  const StreamArgsCompleter();
  Stream<A> getIsolateResult(
      {required String streamId, List<int>? encryptedPart});
  T parsResult(A result);
  MessageArgsStream toRequest({required S message, required String streamId});
  void add(MessageArgsStream args);
  Stream<T> result({List<int>? encryptedPart});
  E cast<E extends CborMessageArgs>() {
    return this as E;
  }
}

abstract class CryptoArgsCompleter<T, A extends CborMessageArgs>
    extends CborArgsCompleter implements MessageArgsRequestable {
  const CryptoArgsCompleter() : super();
  A getResult();
  T parsResult(A result);
  T result();
}

abstract class NoneEncryptedArgsCompleter<T, A extends CborMessageArgs>
    extends CborArgsCompleter implements MessageArgsRequestable {
  const NoneEncryptedArgsCompleter() : super();
  Future<A> getResult({List<int>? encryptedPart});
  T parsResult(A result);
  Future<T> result({List<int>? encryptedPart});
}

abstract class WalletArgsCompleter<T, A extends CborMessageArgs>
    extends CborArgsCompleter {
  const WalletArgsCompleter() : super();
  A getResult({required WalletMasterKeys wallet, required List<int> key});
  T parsResult(A result);
  T result({required WalletMasterKeys wallet, required List<int> key});
}

class WalletArgs<T, A extends CborMessageArgs,
    R extends WalletArgsCompleter<T, A>> extends WalletArgsRequestable<R> {
  @override
  final R args;
  final int version;
  final List<int> nonce;
  final List<int> walletData;
  final List<int> key;
  WalletArgs({
    required this.args,
    required this.version,
    required List<int> walletData,
    required List<int> key,
    required List<int> nonce,
  })  : walletData = walletData.asImmutableBytes,
        key = key.asImmutableBytes,
        nonce = nonce.asImmutableBytes;

  factory WalletArgs.fromStorage(
      {required R args,
      required List<int> encryptedMasterKey,
      required List<int> key}) {
    try {
      final CborListValue values =
          CborSerializable.decode(cborBytes: encryptedMasterKey);
      return WalletArgs(
          args: args,
          version: values.elementAt(0),
          nonce: values.elementAt(1),
          walletData: values.elementAt(2),
          key: key);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }
  factory WalletArgs.deserialize({List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: ArgsType.wallet.tag);
    final WalletArgsCompleter args =
        WalletRequest.deserialize(object: values.getCborTag(0));
    if (args is! R) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return WalletArgs(
        args: args,
        version: values.elementAt(1),
        walletData: values.elementAt(2),
        nonce: values.elementAt(3),
        key: values.elementAt(4));
  }

  A getResult() {
    final masterKey = CryptoRequestReadMasterKey.getWalletMasterKeys(
        nonce: nonce, walletData: walletData, key: key);
    return args.getResult(wallet: masterKey, key: key);
  }

  T parseResult(A result) {
    return args.parsResult(result);
  }

  T result() {
    return parseResult(getResult());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [args.toCbor(), version, walletData, nonce, key]),
        ArgsType.wallet.tag);
  }

  @override
  ArgsType get type => ArgsType.wallet;
}
