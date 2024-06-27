import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/keys/keys/encrypted_derived_key.dart';
import 'package:mrt_wallet/wallet/models/setting/models/setting.dart';
import 'encrypted_imported.dart';

class EncryptedMasterKey {
  EncryptedMasterKey(
      {required this.checksum,
      required List<int> keyBytes,
      required List<EncryptedCustomKey> customKeys,
      required List<EncryptedDerivedKey> derivedKeys,
      required this.setting})
      : masterKey = List<int>.unmodifiable(keyBytes),
        customKeys = List<EncryptedCustomKey>.unmodifiable(customKeys),
        derivedKeys = List<EncryptedDerivedKey>.unmodifiable(derivedKeys);
  EncryptedMasterKey updateSetting(WalletSetting newSetting) {
    return EncryptedMasterKey(
        checksum: checksum,
        customKeys: customKeys,
        keyBytes: masterKey,
        setting: newSetting,
        derivedKeys: derivedKeys);
  }

  final String checksum;
  final List<int> masterKey;
  final List<EncryptedCustomKey> customKeys;
  final List<EncryptedDerivedKey> derivedKeys;
  final WalletSetting setting;
  CborListValue toCbor() {
    return CborObject.fromCbor(masterKey) as CborListValue;
  }
}
