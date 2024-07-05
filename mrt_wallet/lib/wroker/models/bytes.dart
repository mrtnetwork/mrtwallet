import 'package:blockchain_utils/cbor/cbor.dart'
    show CborBytesValue, CborListValue, CborTagValue;
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';

class _ArgsBytesConst {
  static const List<int> twoBytes = [1, 2];
  static const List<int> oneBytes = [1, 1];
  static const List<int> threeBytes = [1, 3];
  static const List<int> exception = [0, 0];
  static const List<int> restoreBackup = [1, 4];
}

enum ArgsType {
  oneArg(_ArgsBytesConst.oneBytes),
  twoArgs(_ArgsBytesConst.twoBytes),
  threeArgs(_ArgsBytesConst.threeBytes),
  exception(_ArgsBytesConst.exception),
  restoreBackup(_ArgsBytesConst.restoreBackup);

  final List<int> tag;
  const ArgsType(this.tag);
}

abstract class ArgsBytes with CborSerializable {
  abstract final ArgsType type;
  static T deserialize<T extends ArgsBytes>(List<int> bytes) {
    final CborTagValue cbor = CborSerializable.toTagValue(bytes);
    final CborListValue values = cbor.getList;
    ArgsBytes args;
    if (BytesUtils.bytesEqual(cbor.tags, _ArgsBytesConst.oneBytes)) {
      args = OneArgBytes(keyOne: values.elementAt(0));
    } else if (BytesUtils.bytesEqual(cbor.tags, _ArgsBytesConst.twoBytes)) {
      args = TwoArgsBytes(
          keyOne: values.elementAt(0), keyTwo: values.elementAt(1));
    } else if (BytesUtils.bytesEqual(cbor.tags, _ArgsBytesConst.threeBytes)) {
      args = ThreeArgsBytes(
          keyOne: values.elementAt(0),
          keyTwo: values.elementAt(1),
          keyThree: values.elementAt(2));
    } else if (BytesUtils.bytesEqual(cbor.tags, _ArgsBytesConst.exception)) {
      args = ExceptionArg(StringUtils.decode(values.elementAt(0)));
    } else {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }
}

class TwoArgsBytes implements ArgsBytes {
  final List<int> keyOne;
  final List<int> keyTwo;
  TwoArgsBytes({required List<int> keyOne, required List<int> keyTwo})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true),
        keyTwo = BytesUtils.toBytes(keyTwo, unmodifiable: true);
  factory TwoArgsBytes.deserialize(List<int> bytes) {
    final CborListValue values =
        CborSerializable.decodeCborTags(bytes, null, _ArgsBytesConst.twoBytes);
    return TwoArgsBytes(
        keyOne: values.elementAt(0), keyTwo: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(keyOne), CborBytesValue(keyTwo)]),
        _ArgsBytesConst.twoBytes);
  }

  @override
  ArgsType get type => ArgsType.twoArgs;
}

class OneArgBytes implements ArgsBytes {
  final List<int> keyOne;
  OneArgBytes({required List<int> keyOne})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true);
  factory OneArgBytes.deserialize(List<int> bytes) {
    final CborListValue values =
        CborSerializable.decodeCborTags(bytes, null, _ArgsBytesConst.oneBytes);
    return OneArgBytes(keyOne: values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([CborBytesValue(keyOne)]),
        _ArgsBytesConst.oneBytes);
  }

  @override
  ArgsType get type => ArgsType.oneArg;
}

class ThreeArgsBytes implements ArgsBytes {
  final List<int> keyOne;
  final List<int> keyTwo;
  final List<int> keyThree;
  ThreeArgsBytes(
      {required List<int> keyOne,
      required List<int> keyTwo,
      required List<int> keyThree})
      : keyOne = BytesUtils.toBytes(keyOne, unmodifiable: true),
        keyTwo = BytesUtils.toBytes(keyTwo, unmodifiable: true),
        keyThree = BytesUtils.toBytes(keyThree, unmodifiable: true);
  factory ThreeArgsBytes.deserialize(List<int> bytes) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, null, _ArgsBytesConst.threeBytes);
    return ThreeArgsBytes(
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
        _ArgsBytesConst.threeBytes);
  }

  @override
  ArgsType get type => ArgsType.threeArgs;
}

class ExceptionArg implements ArgsBytes {
  final String message;
  const ExceptionArg(this.message);
  factory ExceptionArg.deserialize(List<int> bytes) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, null, _ArgsBytesConst.threeBytes);
    return ExceptionArg(StringUtils.decode(values.elementAt(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(StringUtils.encode(message))]),
        _ArgsBytesConst.exception);
  }

  @override
  ArgsType get type => ArgsType.exception;
}
