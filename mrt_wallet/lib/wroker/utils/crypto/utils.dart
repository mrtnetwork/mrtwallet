import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class WorkerCryptoUtils {
  static List<int> generateNonce(List<int> seed) {
    final hasher = SHAKE128();
    final digest = List<int>.unmodifiable(hasher.update(seed).digest(12));
    hasher.clean();
    return digest;
  }

  static List<int> hashKey(
      {required List<int> key, required List<int> checksum}) {
    final List<int> keyBytes = SHA3.hash(List.from([...key, ...checksum]));
    return List<int>.unmodifiable(
        keyBytes.sublist(0, WalletProviderConst.encryptionKeyLength));
  }

  static List<int> encryptChacha(
      {required List<int> key,
      required List<int> nonce,
      required List<int> data}) {
    final chacha = ChaCha20Poly1305(key);
    return chacha.encrypt(nonce, data);
  }

  static List<int>? decryptChacha({
    required List<int> key,
    required List<int> nonce,
    required List<int> data,
  }) {
    final chacha = ChaCha20Poly1305(key);
    final decrypt = chacha.decrypt(nonce, data);
    if (decrypt != null) {
      return List<int>.unmodifiable(decrypt);
    }
    return decrypt;
  }
}
