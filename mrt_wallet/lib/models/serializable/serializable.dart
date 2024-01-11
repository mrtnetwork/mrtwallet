import 'package:blockchain_utils/blockchain_utils.dart';

mixin CborSerializable {
  CborTagValue toCbor();

  static T decodeCborTags<T extends CborObject>(
      List<int>? cborBytes, CborObject? object, List<int> tags) {
    assert(cborBytes != null || object != null,
        "cbor bytes or cbor object must not be null");

    final cbor = object ?? CborObject.fromCbor(cborBytes!);

    return validateCbor(cbor, tags);
  }

  static T validateCbor<T extends CborObject>(CborObject cbor, List<int> tags) {
    if (cbor is! CborTagValue) {
      throw FormatException("invalid cbor types ${cbor.runtimeType}");
    }
    if (!bytesEqual(cbor.tags, tags)) {
      throw FormatException(
          "invalid cbor tags got ${cbor.tags} excepted $tags");
    }
    return cbor.value;
  }
}
