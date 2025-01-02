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

  static List<List<int>> divideRange(
      {required int start, required int end, required int numberOfThreads}) {
    final totalRange = end - start + 1;
    if (totalRange <= 500) {
      return [
        [start, end]
      ];
    }

    // Calculate chunk size based on the range and threads.
    int chunkSize = totalRange ~/ numberOfThreads;

    // Ensure chunk size is at least 500.
    if (chunkSize < 500) {
      chunkSize = 500;
      // Recalculate the number of threads based on 500 per chunk.
      numberOfThreads = totalRange ~/ 500;
    }
    int remainder = totalRange % numberOfThreads;
    final List<List<int>> ranges = [];
    int currentStart = start;

    for (int i = 0; i < numberOfThreads; i++) {
      // For all but the last chunk, subtract 1 to ensure proper chunk size.
      int currentEnd = currentStart + chunkSize - 1;

      // For the last chunk, make sure the end is equal to `end`.
      if (i == numberOfThreads - 1) {
        currentEnd = end;
      } else if (remainder > 0) {
        // Adjust the range if there's a remainder.
        currentEnd++;
        remainder--;
      }

      ranges.add([currentStart, currentEnd]);

      // Update the currentStart for the next range to start from the previous end.
      currentStart = currentEnd;
    }
    return ranges;
  }
}
