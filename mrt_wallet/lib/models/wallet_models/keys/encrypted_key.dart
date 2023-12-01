import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'setting.dart';

class EncryptedMasterKey {
  EncryptedMasterKey(
      {required this.checksum,
      required List<int> keyBytes,
      required List<EncryptedCustomKey> customKeys,
      required this.setting})
      : masterKey = List<int>.unmodifiable(keyBytes),
        customKeys = List<EncryptedCustomKey>.unmodifiable(customKeys);
  EncryptedMasterKey updateSetting(WalletSetting newSetting) {
    return EncryptedMasterKey(
        checksum: checksum,
        customKeys: customKeys,
        keyBytes: masterKey,
        setting: newSetting);
  }

  final String checksum;
  final List<int> masterKey;
  final List<EncryptedCustomKey> customKeys;
  final WalletSetting setting;
  CborListValue toCbor() {
    return CborObject.fromCbor(masterKey) as CborListValue;
  }
}

class EncryptedCustomKey with Equatable {
  final String publicKey;
  final String id;
  final EllipticCurveTypes type;
  final DateTime created;
  const EncryptedCustomKey(
      {required this.publicKey,
      required this.type,
      required this.id,
      required this.created});

  @override
  List get variabels => [publicKey, id, type];
}
