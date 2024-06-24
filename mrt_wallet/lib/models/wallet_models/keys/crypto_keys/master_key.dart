import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/bip32_address_index.dart';
import 'package:mrt_wallet/models/wallet_models/keys/keys.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

enum SeedGenerationType {
  bip39("Bip39"),
  byronLegacySeed("ByronLegacySeed"),
  icarus("icarus"),
  none("none");

  final String name;
  const SeedGenerationType(this.name);
  static SeedGenerationType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () =>
            throw const MessageException("Invalid seed generation type."));
  }
}

class WalletMasterKeys with CborSerializable {
  WalletMasterKeys._(
    this.mnemonic,
    List<int> seedBytes,
    this.customKeys,
    this.setting,
    List<int> cardanoLegacyByronSeed,
    List<int> cardanoIcarusSeed,
    List<DerivedKey> derivedKey,
  )   : seed = BytesUtils.toBytes(seedBytes),
        cardanoLegacyByronSeed = BytesUtils.toBytes(cardanoLegacyByronSeed),
        cardanoIcarusSeed = BytesUtils.toBytes(cardanoIcarusSeed),
        derivedKeys = List<DerivedKey>.unmodifiable(derivedKey);
  List<int> getSeed({SeedGenerationType type = SeedGenerationType.bip39}) {
    switch (type) {
      case SeedGenerationType.bip39:
        return seed;
      case SeedGenerationType.icarus:
        return cardanoIcarusSeed;
      default:
        return cardanoLegacyByronSeed;
    }
  }

  WalletMasterKeys addKey(WalletCustomKeys newKey) {
    return WalletMasterKeys._(
        mnemonic,
        seed,
        List.unmodifiable([newKey, ...customKeys]),
        setting,
        cardanoLegacyByronSeed,
        cardanoIcarusSeed,
        derivedKeys);
  }

  WalletMasterKeys addDerivedKey(DerivedKey newKey) {
    return WalletMasterKeys._(mnemonic, seed, customKeys, setting,
        cardanoLegacyByronSeed, cardanoIcarusSeed, [newKey, ...derivedKeys]);
  }

  WalletMasterKeys removeKey(String keyId) {
    final accounts = customKeys.where((element) => element.checksum != keyId);
    return WalletMasterKeys._(mnemonic, seed, List.unmodifiable(accounts),
        setting, cardanoLegacyByronSeed, cardanoIcarusSeed, derivedKeys);
  }

  WalletMasterKeys updateSetting(WalletSetting newSetting) {
    return WalletMasterKeys._(mnemonic, seed, customKeys, newSetting,
        cardanoLegacyByronSeed, cardanoIcarusSeed, derivedKeys);
  }

  final WalletSetting setting;
  final Mnemonic mnemonic;
  final List<int> seed;
  final List<int> cardanoLegacyByronSeed;
  final List<int> cardanoIcarusSeed;

  static Future<WalletMasterKeys> setup(String mnemonic, String passphrase,
      {List<WalletCustomKeys> customKeys = const [],
      List<DerivedKey> derivedKeys = const []}) async {
    final seed =
        await BlockchainUtils.mnemonicToSeed(mnemonic, passphrase: passphrase);
    final icarus = CardanoIcarusSeedGenerator(mnemonic).generate();
    final cardanoLegacy = CardanoByronLegacySeedGenerator(mnemonic).generate();
    return WalletMasterKeys._(
        Mnemonic.fromString(mnemonic),
        seed,
        List.unmodifiable(customKeys),
        WalletSetting.defaultSetting(),
        cardanoLegacy,
        icarus,
        derivedKeys);
  }

  factory WalletMasterKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.mnemonic);
      final String mnemonic = cbor.value[0].value;
      final List<int> seed = cbor.value[1].value;
      final CborListValue customKeys = cbor.value[2];
      final WalletSetting setting =
          WalletSetting.fromCborBytesOrObject(obj: cbor.value[3]);
      final cardanoLegacy = cbor.elementAt<List<int>?>(4) ??
          CardanoByronLegacySeedGenerator(mnemonic).generate();
      final icarus = cbor.elementAt<List<int>?>(5) ??
          CardanoIcarusSeedGenerator(mnemonic).generate();
      final List<DerivedKey>? derivedKeys = cbor
          .getElement<CborListValue?>(6)
          ?.to<List<DerivedKey>, List>((e) =>
              e.map((i) => DerivedKey.fromCborBytesOrObject(obj: i)).toList());

      return WalletMasterKeys._(
          Mnemonic.fromString(mnemonic),
          seed,
          List<WalletCustomKeys>.unmodifiable(customKeys.value
              .map((e) => WalletCustomKeys.fromCborBytesOrObject(obj: e))
              .toList()),
          setting,
          cardanoLegacy,
          icarus,
          derivedKeys ?? <DerivedKey>[]);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  List<String> get toList => mnemonic.toList();
  final List<WalletCustomKeys> customKeys;
  final List<DerivedKey> derivedKeys;
  @override
  CborTagValue toCbor([bool withSeed = true]) {
    return CborTagValue(
        CborListValue.fixedLength([
          mnemonic.toStr(),
          if (withSeed) CborBytesValue(seed) else const CborBytesValue([]),
          CborListValue.fixedLength(customKeys.map((e) => e.toCbor()).toList()),
          setting.toCbor(),
          if (withSeed)
            CborBytesValue(cardanoLegacyByronSeed)
          else
            const CborBytesValue([]),
          if (withSeed)
            CborBytesValue(cardanoIcarusSeed)
          else
            const CborBytesValue([]),
          CborListValue.fixedLength(
              derivedKeys.map((e) => e.toCbor()).toList()),
        ]),
        WalletModelCborTagsConst.mnemonic);
  }

  WalletCustomKeys? getKeyById(String keyId) {
    try {
      return customKeys.firstWhere((element) => element.checksum == keyId);
    } on StateError {
      return null;
    }
  }

  DerivedKey? getDerivedKey(String id) {
    try {
      return derivedKeys.firstWhere((element) => element.id == id);
    } on StateError {
      return null;
    }
  }

  Bip32Base toKey(AddressDerivationIndex key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (key is! Bip32AddressIndex) {
      throw WalletExceptionConst.multiSigDerivationNotSuported;
    }
    if (key.isImportedKey) {
      final customKey = getKeyById(key.importedKeyId!);
      if (customKey == null) {
        throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
      return customKey.toKey(key, maxLevel: maxLevel);
    }
    final seedBytes = getSeed(type: key.seedGeneration);
    final bip32Key = BlockchainUtils.seedToBip32(
        seedBytes: seedBytes, coin: key.currencyCoin);
    return key.derive(bip32Key, maxLevel: maxLevel);
  }
}
