import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/requests/read_master_key.dart';

class MessageArgsTags {
  static const List<int> twoBytes = [1, 2];
  static const List<int> oneBytes = [1, 1];
  static const List<int> threeBytes = [1, 3];
  static const List<int> exception = [0, 0];
  static const List<int> network = [2, 0];
  static const List<int> wallet = [3, 0];
}

enum ArgsType {
  oneArg(MessageArgsTags.oneBytes),
  twoArgs(MessageArgsTags.twoBytes),
  threeArgs(MessageArgsTags.threeBytes),
  exception(MessageArgsTags.exception),
  network(MessageArgsTags.network),
  wallet(MessageArgsTags.wallet);

  final List<int> tag;
  const ArgsType(this.tag);
  static ArgsType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

abstract class MessageArgs with CborSerializable {
  abstract final ArgsType type;
  static T deserialize<T extends MessageArgs>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final type = ArgsType.fromTag(cbor.tags);
    MessageArgs args;
    switch (type) {
      case ArgsType.oneArg:
        args = MessageArgsOneBytes.deserialize(object: cbor);
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
      case ArgsType.network:
        args = CryptoArgs.deserialize(object: cbor);
        break;
      case ArgsType.wallet:
        args = WalletArgs.deserialize(object: cbor);
        break;

      default:
        throw WalletExceptionConst.invalidRequest;
    }
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return args;
  }
}

class MessageArgsTwoBytes implements MessageArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  MessageArgsTwoBytes({required List<int> keyOne, required List<int> keyTwo})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true),
        keyTwo = BytesUtils.toBytes(keyTwo, unmodifiable: true);
  factory MessageArgsTwoBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: MessageArgsTags.twoBytes);
    return MessageArgsTwoBytes(
        keyOne: values.elementAt(0), keyTwo: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(keyOne), CborBytesValue(keyTwo)]),
        MessageArgsTags.twoBytes);
  }

  @override
  ArgsType get type => ArgsType.twoArgs;
}

class MessageArgsOneBytes implements MessageArgs {
  final List<int> keyOne;
  MessageArgsOneBytes({required List<int> keyOne})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true);
  factory MessageArgsOneBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: MessageArgsTags.oneBytes);
    return MessageArgsOneBytes(keyOne: values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([CborBytesValue(keyOne)]),
        MessageArgsTags.oneBytes);
  }

  @override
  ArgsType get type => ArgsType.oneArg;
}

class MessageArgsThreeBytes implements MessageArgs {
  final List<int> keyOne;
  final List<int> keyTwo;
  final List<int> keyThree;
  MessageArgsThreeBytes(
      {required List<int> keyOne,
      required List<int> keyTwo,
      required List<int> keyThree})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true),
        keyTwo = BytesUtils.toBytes(keyTwo, unmodifiable: true),
        keyThree = BytesUtils.toBytes(keyThree, unmodifiable: true);
  factory MessageArgsThreeBytes.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: MessageArgsTags.threeBytes);
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
        MessageArgsTags.threeBytes);
  }

  @override
  ArgsType get type => ArgsType.threeArgs;
}

class MessageArgsException implements MessageArgs {
  final String message;
  const MessageArgsException(this.message);
  factory MessageArgsException.deserialize(
      {List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: MessageArgsTags.exception);
    return MessageArgsException(StringUtils.decode(values.elementAt(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(StringUtils.encode(message))]),
        MessageArgsTags.exception);
  }

  @override
  ArgsType get type => ArgsType.exception;

  @override
  String toString() {
    return "MessageArgsException:$message";
  }
}

abstract class MessageArgsCompleter<T, A extends MessageArgs>
    with CborSerializable {
  A getResult();
  T parsResult(A result);
  T result();
}

abstract class WalletMessageArgsCompleter<T, A extends MessageArgs>
    with CborSerializable {
  A getResult({required WalletMasterKeys wallet, required List<int> key});
  T parsResult(A result);
  T result({required WalletMasterKeys wallet, required List<int> key});
}

class CryptoArgs<T extends MessageArgsCompleter> implements MessageArgs {
  final T args;
  const CryptoArgs(this.args);
  factory CryptoArgs.deserialize({List<int>? bytes, CborTagValue? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: object, tags: MessageArgsTags.network);
    final MessageArgsCompleter args =
        CryptoRequest.deserialize(object: values.getCborTag(0));
    if (args is! T) {
      throw WalletExceptionConst.invalidArgruments("$T", "${args.runtimeType}");
    }
    return CryptoArgs(args);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([args.toCbor()]), MessageArgsTags.network);
  }

  @override
  ArgsType get type => ArgsType.network;
}

class WalletArgs<T, A extends MessageArgs,
    R extends WalletMessageArgsCompleter<T, A>> implements MessageArgs {
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
  })  : walletData = BytesUtils.toBytes(walletData, unmodifiable: true),
        key = BytesUtils.toBytes(key, unmodifiable: true),
        nonce = BytesUtils.toBytes(nonce, unmodifiable: true);

  factory WalletArgs.fromStorage({
    required R args,
    required List<int> encryptedMasterKey,
    required List<int> key,
  }) {
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
        cborBytes: bytes, object: object, tags: MessageArgsTags.wallet);
    final WalletMessageArgsCompleter args =
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
        MessageArgsTags.wallet);
  }

  @override
  ArgsType get type => ArgsType.wallet;
}
