import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/models/key_type.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'imported.dart';

class WalletMasterKeys with CborSerializable {
  final Mnemonic mnemonic;
  final List<int> seed;
  final List<int> entopySeed;
  final List<int> cardanoLegacyByronSeed;
  final List<int> cardanoIcarusSeed;
  final List<int> checksum;
  WalletMasterKeys._({
    required this.mnemonic,
    required List<int> seedBytes,
    required this.customKeys,
    required List<int> entropySeedBytes,
    required List<int> cardanoLegacyByronSeed,
    required List<int> cardanoIcarusSeed,
    required List<int> checksum,
  })  : seed = BytesUtils.toBytes(seedBytes, unmodifiable: true),
        cardanoLegacyByronSeed =
            BytesUtils.toBytes(cardanoLegacyByronSeed, unmodifiable: true),
        cardanoIcarusSeed =
            BytesUtils.toBytes(cardanoIcarusSeed, unmodifiable: true),
        checksum = BytesUtils.toBytes(checksum, unmodifiable: true),
        entopySeed = BytesUtils.toBytes(entropySeedBytes, unmodifiable: true);
  List<int> getSeed(SeedTypes type) {
    switch (type) {
      case SeedTypes.bip39:
        return seed;
      case SeedTypes.bip39Entropy:
        return entopySeed;
      case SeedTypes.icarus:
        return cardanoIcarusSeed;
      default:
        return cardanoLegacyByronSeed;
    }
  }

  WalletMasterKeys _addKey(List<ImportedKeyStorage> newKey) {
    return WalletMasterKeys._(
        mnemonic: mnemonic,
        seedBytes: seed,
        customKeys: List.unmodifiable([...newKey, ...customKeys]),
        cardanoLegacyByronSeed: cardanoLegacyByronSeed,
        cardanoIcarusSeed: cardanoIcarusSeed,
        checksum: checksum,
        entropySeedBytes: entopySeed);
  }

  WalletMasterKeys removeKey(String keyId) {
    final accounts = customKeys.where((element) => element.checksum != keyId);
    return WalletMasterKeys._(
        mnemonic: mnemonic,
        seedBytes: seed,
        customKeys: List.unmodifiable(accounts),
        cardanoLegacyByronSeed: cardanoLegacyByronSeed,
        cardanoIcarusSeed: cardanoIcarusSeed,
        checksum: checksum,
        entropySeedBytes: entopySeed);
  }

  static WalletMasterKeys setup({
    required String mnemonic,
    required List<int> seed,
    required List<int> entropySeed,
    required List<int> icarus,
    required List<int> cardanoLegacy,
    required List<int> checksum,
    List<ImportedKeyStorage> customKeys = const [],
  }) {
    return WalletMasterKeys._(
        mnemonic: Mnemonic.fromString(mnemonic),
        seedBytes: seed,
        customKeys: List.unmodifiable(customKeys),
        cardanoLegacyByronSeed: cardanoLegacy,
        cardanoIcarusSeed: icarus,
        checksum: checksum,
        entropySeedBytes: entropySeed);
  }

  factory WalletMasterKeys.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CryptoKeyConst.mnemonic,
      );
      final String mnemonic = cbor.elementAt(0);
      final List<int> seed = cbor.elementAt(1);
      final CborListValue customKeys = cbor.value[2];
      final cardanoLegacy = cbor.elementAt<List<int>>(4);
      final icarus = cbor.elementAt<List<int>>(5);
      final entropySeed = cbor.elementAt<List<int>>(7);
      return WalletMasterKeys._(
          mnemonic: Mnemonic.fromString(mnemonic),
          seedBytes: seed,
          customKeys: List<ImportedKeyStorage>.unmodifiable(customKeys.value
              .map((e) => ImportedKeyStorage.fromCborBytesOrObject(obj: e))
              .toList()),
          cardanoLegacyByronSeed: cardanoLegacy,
          cardanoIcarusSeed: icarus,
          checksum: cbor.elementAt<List<int>>(6),
          entropySeedBytes: entropySeed);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }
  factory WalletMasterKeys.deserializeBackup(
      {List<int>? bytes, CborObject? obj, String? hex}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes,
          object: obj,
          hex: hex,
          tags: CryptoKeyConst.mnemonic);
      final String mnemonic = cbor.elementAt(0);
      final CborListValue customKeys = cbor.value[2];
      return WalletMasterKeys._(
          mnemonic: Mnemonic.fromString(mnemonic),
          seedBytes: const [],
          customKeys: List<ImportedKeyStorage>.unmodifiable(customKeys.value
              .map((e) => ImportedKeyStorage.fromCborBytesOrObject(obj: e))
              .toList()),
          cardanoLegacyByronSeed: const [],
          cardanoIcarusSeed: const [],
          checksum: cbor.elementAt<List<int>>(6),
          entropySeedBytes: const []);
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  List<String> get toList => mnemonic.toList();
  final List<ImportedKeyStorage> customKeys;
  @override
  CborTagValue toCbor({bool backup = false}) {
    return CborTagValue(
        CborListValue.fixedLength([
          mnemonic.toStr(),
          if (backup) const CborNullValue() else CborBytesValue(seed),
          CborListValue.fixedLength(customKeys.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          if (backup) ...[
            const CborNullValue(),
            const CborNullValue()
          ] else ...[
            CborBytesValue(cardanoLegacyByronSeed),
            CborBytesValue(cardanoIcarusSeed)
          ],
          CborBytesValue(checksum),
          if (backup) const CborNullValue() else CborBytesValue(entopySeed)
        ]),
        CryptoKeyConst.mnemonic);
  }

  ImportedKeyStorage? getKeyById(String keyId) {
    try {
      return customKeys.firstWhere((element) => element.checksum == keyId);
    } on StateError {
      return null;
    }
  }

  PrivateKeyData toKey(AddressDerivationIndex key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (key.isMultiSig) {
      throw WalletExceptionConst.multiSigDerivationNotSuported;
    }
    if (key.isImportedKey) {
      final customKey = getKeyById(key.importedKeyId!);
      if (customKey == null) {
        throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
      return customKey.toKey(key, maxLevel: maxLevel);
    }
    final seedBytes = getSeed(key.seedGeneration);
    final bip32Key = PrivateKeyData.fromSeed(
        seedBytes: seedBytes, coin: key.currencyCoin, keyName: key.name);
    return key.derive(bip32Key, maxLevel: maxLevel);
  }

  PrivateKeyData getImportedKey(String keyId) {
    final importedKey = getKeyById(keyId);
    if (importedKey == null) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    final keyInfo = importedKey.toKey(null);
    return keyInfo;
  }

  List<CryptoPrivateKeyData> readKeys(
      List<AccessCryptoPrivateKeyRequest> requestKeys) {
    final List<CryptoPrivateKeyData> keys = [];
    for (final i in requestKeys) {
      final key = toKey(i.index, maxLevel: Bip44Levels.fromInt(i.maxLevel));
      keys.add(key);
    }
    return keys;
  }

  List<CryptoPublicKeyData> readPublicKeys(
      List<AccessCryptoPrivateKeyRequest> requestKeys) {
    final List<CryptoPublicKeyData> pubKeys = [];
    for (final i in requestKeys) {
      final bool byronLegacy =
          i.index.currencyCoin.proposal == CustomProposal.cip0019;
      final PrivateKeyData privateKey = toKey(i.index,
          maxLevel:
              byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex);
      if (!byronLegacy) {
        pubKeys.add(privateKey.publicKey);
        continue;
      }
      Bip32Base bipKey = privateKey.toBipKey();
      if (byronLegacy) {
        final legacy = CardanoByronLegacy.fromBip32(bipKey);
        if (i.index.hdPath != null) {
          bipKey = legacy.bip32.derivePath(i.index.hdPath!);
        }
        pubKeys.add(AdaLegacyPublicKeyData.fromBip32(
            account: bipKey,
            keyName: privateKey.keyName,
            hdPathKey: legacy.hdPathKey));
        continue;
      }
    }
    return pubKeys;
  }

  WalletMasterKeys importCustomKey(ImportedKeyStorage newKey,
      {bool validateChecksum = true}) {
    final ImportedKeyStorage validateKey;
    if (newKey.keyType == CustomKeyType.extendedKey) {
      validateKey = BlockchainUtils.extendeKeyToStorage(
          extendedKey: newKey.extendedPrivateKey, coin: newKey.coin);
    } else {
      validateKey = BlockchainUtils.privateKeyToStorage(
          privateKey: newKey.extendedPrivateKey, coin: newKey.coin);
    }

    if (validateKey.publicKey != newKey.publicKey) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (validateChecksum && validateKey.checksum != newKey.checksum) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (customKeys.contains(newKey) ||
        customKeys.any((e) => e.checksum == newKey.checksum)) {
      throw WalletExceptionConst.keyAlreadyExist;
    }
    return _addKey([newKey]);
  }
}
