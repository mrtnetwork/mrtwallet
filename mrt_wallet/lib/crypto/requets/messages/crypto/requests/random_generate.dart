import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestRandomGenerator<T>
    implements CryptoRequest<List<int>, MessageArgsOneBytes> {
  final int length;
  final List<List<int>> existsKeys;
  CryptoRequestRandomGenerator(
      {required this.length, List<List<int>> existsKeys = const []})
      : existsKeys = List<List<int>>.unmodifiable(List.generate(
            existsKeys.length, (e) => List<int>.unmodifiable(existsKeys[e])));
  factory CryptoRequestRandomGenerator.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.randomGenerator.tag);
    final existsKeys = values
        .elementAt<List<dynamic>>(1)
        .map((e) => (e as CborBytesValue).value);
    return CryptoRequestRandomGenerator(
        length: values.elementAt(0),
        existsKeys: List<List<int>>.from(existsKeys));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          length,
          CborListValue.fixedLength(
              existsKeys.map((e) => CborBytesValue(e)).toList())
        ]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.randomGenerator;

  static List<int> generateRandm(
      {required int length, required List<List<int>> existsKeys}) {
    if (existsKeys.isEmpty) {
      return QuickCrypto.generateRandom(length);
    }
    while (true) {
      final rand = QuickCrypto.generateRandom(length);
      bool hasEqual = false;
      for (final i in existsKeys) {
        if (BytesUtils.bytesEqual(rand, i)) {
          hasEqual = true;
          break;
        }
      }
      if (!hasEqual) {
        return rand;
      }
    }
  }

  @override
  MessageArgsOneBytes getResult() {
    return MessageArgsOneBytes(
        keyOne: generateRandm(length: length, existsKeys: existsKeys));
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  List<int> result() {
    return generateRandm(length: length, existsKeys: existsKeys);
  }
}
