import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/keys/encrypted_derived_key.dart';
import 'package:mrt_wallet/models/wallet_models/keys/keys.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';

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

class EncryptedCustomKey with Equatable {
  final String publicKey;
  final String id;
  final CryptoCoins coin;
  final DateTime created;
  final String? name;
  final CustomKeyType keyType;
  const EncryptedCustomKey(
      {required this.publicKey,
      required this.coin,
      required this.id,
      required this.created,
      required this.name,
      required this.keyType});

  @override
  List get variabels => [publicKey, id, coin, keyType.name];

  String networkPubKey(AppNetworkImpl network) {
    if (network is AppXRPNetwork) {
      return RippleUtils.toRipplePublicKey(publicKey);
    }
    return publicKey;
  }
}
