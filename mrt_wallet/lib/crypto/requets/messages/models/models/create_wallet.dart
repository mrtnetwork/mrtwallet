import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';

class CryptoCreateWalletResponse {
  final EncryptedMasterKey masterKey;
  final String storageData;
  final List<int> checksum;
  CryptoCreateWalletResponse(
      {required this.masterKey,
      required this.storageData,
      required List<int> checksum})
      : checksum = checksum.asImmutableBytes;
}
