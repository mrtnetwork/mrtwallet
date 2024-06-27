import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/compute/core/compute.dart';

class SecretStorageCompute {
  static Future<String> encrypt(String credentials, String password,
      {int scryptN = 8192,
      int p = 1,
      SecretWalletEncoding encoding = SecretWalletEncoding.cbor}) {
    String encrypt(SecretWalletEncoding enc) {
      final secureStorage = Web3SecretStorageDefinationV3.encode(
          StringUtils.toBytes(credentials), password);
      return secureStorage.encrypt(encoding: enc);
    }

    return AppCompute.compute(encrypt, encoding);
  }

  static Future<List<int>> decrypt(String backup, String password,
      {int scryptN = 8192,
      int p = 1,
      SecretWalletEncoding encoding = SecretWalletEncoding.cbor}) {
    List<int> encrypt(SecretWalletEncoding enc) {
      final secureStorage =
          Web3SecretStorageDefinationV3.decode(backup, password, encoding: enc);
      return secureStorage.data;
    }

    return AppCompute.compute(encrypt, encoding);
  }
}
