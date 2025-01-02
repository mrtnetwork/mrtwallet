import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';

class CryptoEncryptChachaResponse {
  final List<int> encrypted;
  final List<int> nonce;
  CryptoEncryptChachaResponse(
      {required List<int> encrypted, required List<int> nonce})
      : encrypted = encrypted.asImmutableBytes,
        nonce = nonce.asImmutableBytes;
  String get encryptedHex => BytesUtils.toHexString(encrypted);
  String get nonceHex => BytesUtils.toHexString(nonce);
}

class CryptoDecryptChachaResponse {
  final List<int> decrypted;
  CryptoDecryptChachaResponse(List<int> decrypted)
      : decrypted = decrypted.asImmutableBytes;
}
