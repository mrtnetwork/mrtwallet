import 'package:blockchain_utils/blockchain_utils.dart';

class StorageItem {
  final List<int> nonce;
  final List<int> encryptedValue;
  StorageItem({required List<int> nonce, required List<int> encryptedValue})
      : nonce = List<int>.unmodifiable(nonce),
        encryptedValue = List<int>.unmodifiable(encryptedValue);
  static StorageItem fromStorage(String? data) {
    final CborListValue cbor = CborObject.fromCborHex(data!) as CborListValue;
    return StorageItem(
        nonce: (cbor.value[0] as CborBytesValue).value,
        encryptedValue: (cbor.value[1] as CborBytesValue).value);
  }

  CborListValue toCbor() {
    return CborListValue.fixedLength(
        [CborBytesValue(nonce), CborBytesValue(encryptedValue)]);
  }
}
