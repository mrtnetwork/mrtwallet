import 'package:mrt_wallet/wroker/keys/keys.dart';

class CryptoGenerateMasterKeyResponse {
  final EncryptedMasterKey masterKey;
  final String storageData;
  CryptoGenerateMasterKeyResponse(
      {required this.masterKey, required this.storageData});
}
