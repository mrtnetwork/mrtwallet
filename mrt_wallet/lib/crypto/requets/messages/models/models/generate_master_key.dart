import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';

class CryptoGenerateMasterKeyResponse {
  final EncryptedMasterKey masterKey;
  final String storageData;
  final List<int> walletKey;
  CryptoGenerateMasterKeyResponse({
    required this.masterKey,
    required this.storageData,
    required List<int> walletKey,
  }) : walletKey = BytesUtils.toBytes(walletKey, unmodifiable: true);
}
