import 'package:blockchain_utils/utils/binary/utils.dart';

class CryptoEncryptChachaResponse {
  final List<int> encrypted;
  final List<int> nonce;
  CryptoEncryptChachaResponse(
      {required List<int> encrypted, required List<int> nonce})
      : encrypted = BytesUtils.toBytes(encrypted, unmodifiable: true),
        nonce = BytesUtils.toBytes(nonce, unmodifiable: true);
  String get encryptedHex => BytesUtils.toHexString(encrypted);
  String get nonceHex => BytesUtils.toHexString(nonce);
}

class CryptoDecryptChachaResponse {
  final List<int> decrypted;
  CryptoDecryptChachaResponse(List<int> decrypted)
      : decrypted = BytesUtils.toBytes(decrypted, unmodifiable: true);
}
