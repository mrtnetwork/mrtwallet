part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin MasterKeyImpl on WalletCryptoImpl {
  EncryptedMasterKey? _massterKey;
  bool get hasCustomKeys => _massterKey?.customKeys.isNotEmpty ?? false;
  WalletSetting get setting => _massterKey!.setting;
  Future<EncryptedMasterKey> _readMasterKey(
    String encryptedWallet,
    List<int> password,
  ) async {
    final mn = await _masterKeyFromStorage(encryptedWallet, password);
    final bip32 = Bip32Slip10Secp256k1.fromSeed(mn.seed);
    final encrypt = _toMemoryStorage(password, mn.toCbor().encode());
    return EncryptedMasterKey(
        checksum: bip32.publicKey.fingerPrint.toHex(),
        keyBytes: encrypt,
        setting: mn.setting,
        derivedKeys:
            mn.derivedKeys.map((e) => EncryptedDerivedKey(id: e.id)).toList(),
        customKeys: mn.customKeys
            .map((e) => EncryptedCustomKey(
                publicKey: e.publicKey,
                type: e.type,
                id: e.checksum,
                created: e.created,
                name: e.name))
            .toList());
  }

  Bip32Base _getPrivateKey(List<int> password, AddressDerivationIndex keyIndex,
      {SeedGenerationType seedType = SeedGenerationType.bip39}) {
    try {
      switch (keyIndex.runtimeType) {
        case Bip32AddressIndex:
        case ByronLegacyAddressIndex:
        case ImportedAddressIndex:
          final WalletMasterKeys walletMasterKeys =
              _fromMemoryStorage(password, _massterKey!);

          return _getLocalBip32FromKeyIndex(keyIndex, walletMasterKeys,
              seedType: seedType);
        default:
          throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
    } catch (e) {
      rethrow;
    } finally {}
  }

  bool _validateBcakupAccounts(
      WalletMasterKeys masterKey, CryptoAccountAddress address) {
    if (!address.multiSigAccount) {
      final bip32 = _getBip32FromKeyIndex(address.keyIndex, masterKey,
          seedType: address.keyIndex.seedGeneration);
      if (!address.signers.contains(bip32.publicKey.toHex())) {
        return false;
      }
    } else {
      return _validateMultiSigAccount(masterKey, address);
    }
    return true;
  }

  bool _validateMultiSigAccount(
      WalletMasterKeys masterKey, CryptoAccountAddress address) {
    final List<(String, AddressDerivationIndex)> keyDetails =
        (address as MultiSigCryptoAccountAddress).keyDetails;
    for (final i in keyDetails) {
      final bip32 = _getBip32FromKeyIndex(i.$2, masterKey);
      if (!address.signers.contains(bip32.publicKey.toHex())) {
        return false;
      }
    }
    return true;
  }

  String _getImportedKeyFromId(List<int> password, String accountId) {
    final WalletMasterKeys walletMasterKeys =
        _fromMemoryStorage(password, _massterKey!);
    final acc = walletMasterKeys.getKeyById(accountId);

    if (acc == null) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    return acc.extendedPrivateKey;
  }

  Bip32Base _getBip32FromKeyIndex(
      AddressDerivationIndex keyIndex, WalletMasterKeys masterKey,
      {SeedGenerationType seedType = SeedGenerationType.bip39}) {
    if (keyIndex is MultiSigAddressIndex) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }

    if (keyIndex is ByronLegacyAddressIndex) {
      final legacyBip32 =
          CardanoByronLegacyBip32.fromSeed(masterKey.getSeed(type: seedType));
      final legacy = CardanoByronLegacy.fromBip32(legacyBip32);
      return legacy.bip32.derivePath(keyIndex.path);
    } else if (keyIndex is ImportedAddressIndex) {
      final key = masterKey.getKeyById(keyIndex.accountId)!;
      final Bip32Base bip32 = key.toBip32();
      return keyIndex.derive(bip32);
    }
    final Bip32Base bip32 = BlockchainUtils.seedToBip32(
        masterKey.getSeed(type: seedType),
        type: keyIndex.curve,
        coin: keyIndex.currencyCoin);
    return keyIndex.derive(bip32);
  }

  Bip32Base _getLocalBip32FromKeyIndex(
      AddressDerivationIndex keyIndex, WalletMasterKeys masterKey,
      {SeedGenerationType seedType = SeedGenerationType.bip39}) {
    if (keyIndex is MultiSigAddressIndex) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    final keyId = keyIndex.storageKey();
    final derivedKey = masterKey.getDerivedKey(keyId);

    if (derivedKey == null) {
      return _getBip32FromKeyIndex(keyIndex, masterKey, seedType: seedType);
    }
    if (keyIndex is ByronLegacyAddressIndex) {
      final legacyBip32 =
          CardanoByronLegacyBip32.fromExtendedKey(derivedKey.extendedKey);
      final legacy = CardanoByronLegacy.fromBip32(legacyBip32);
      return legacy.bip32.derivePath(keyIndex.path);
    }
    return BlockchainUtils.extendedToBip32(derivedKey.extendedKey,
        type: keyIndex.curve, coin: keyIndex.currencyCoin);
  }

  Future<Mnemonic> _readMnemonic(
    String encryptedWallet,
    List<int> password,
  ) async {
    final mn = await _masterKeyFromStorage(encryptedWallet, password);
    return mn.mnemonic;
  }

  (Bip32Base, DerivedKey?) _getDerivedKey(
      NewAccountParams params, WalletMasterKeys masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    final keyIndex = params.deriveIndex;
    final String keyId = keyIndex.storageKey(maxLevel: maxLevel);
    final localKeyIndex = masterKey.getDerivedKey(keyId);
    if (localKeyIndex != null) {
      if (keyIndex is ByronLegacyAddressIndex) {
        final key =
            CardanoByronLegacyBip32.fromExtendedKey(localKeyIndex.extendedKey);
        return (key, null);
      }
      final key = BlockchainUtils.extendedToBip32(localKeyIndex.extendedKey,
          coin: params.coin);
      return (key, null);
    }
    Bip32Base bip32;
    if (keyIndex is ImportedAddressIndex) {
      final WalletCustomKeys key = masterKey.customKeys
          .firstWhere((element) => element.checksum == keyIndex.accountId);
      bip32 = key.toBip32();
    } else if (keyIndex is ByronLegacyAddressIndex) {
      bip32 = CardanoByronLegacyBip32.fromSeed(
          masterKey.getSeed(type: params.deriveIndex.seedGeneration));
    } else {
      bip32 = BlockchainUtils.seedToBip32(
          masterKey.getSeed(type: params.deriveIndex.seedGeneration),
          coin: params.coin);
    }
    if (keyIndex is! ByronLegacyAddressIndex) {
      bip32 = keyIndex.derive(bip32, maxLevel: maxLevel);
    }
    final derivedKey =
        DerivedKey(extendedKey: bip32.privateKey.toExtended, id: keyId);
    return (bip32, derivedKey);
  }

  (CardanoNewAddressParams, DerivedKey?, DerivedKey?) _deriveCardanoNewAddress(
      CardanoNewAddressParams params, WalletMasterKeys keys) {
    final bip = _getDerivedKey(params, keys);
    DerivedKey? stakeDerivedKey;
    final CardanoAddrDetails addrDetails;
    switch (params.addressType) {
      case ADAAddressType.base:
        final stake =
            _getDerivedKey(params, keys, maxLevel: Bip44Levels.account);
        stakeDerivedKey = stake.$2;
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.$1.publicKey.compressed,
            stakePubkey: stake.$1.derivePath("2/0").publicKey.compressed,
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.enterprise:
      case ADAAddressType.reward:
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.$1.publicKey.compressed,
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.byron:
        if (params.deriveIndex is ByronLegacyAddressIndex) {
          final ByronLegacyAddressIndex deriveIndex =
              params.deriveIndex as ByronLegacyAddressIndex;
          final legacy = CardanoByronLegacy.fromBip32(bip.$1);
          final pubkey = legacy.deriveKey(Bip32KeyIndex(deriveIndex.firstIndex),
              Bip32KeyIndex(deriveIndex.secondIndex));
          addrDetails = CardanoAddrDetails.byron(
              publicKey: pubkey.publicKey.compressed,
              chainCode: pubkey.publicKey.chainCode.toBytes(),
              seedGeneration: params.deriveIndex.seedGeneration,
              hdPathKey: legacy.hdPathKey,
              hdPath: deriveIndex.path);
          break;
        }
        addrDetails = CardanoAddrDetails.byron(
            publicKey: bip.$1.publicKey.compressed,
            chainCode: bip.$1.chainCode.toBytes(),
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      default:
        throw UnimplementedError();
    }
    return (
      params.copyWith(addressDetails: addrDetails),
      bip.$2,
      stakeDerivedKey
    );
  }

  WalletMasterKeys _importCustomKey(
      WalletCustomKeys newKey, List<int> password) {
    final WalletMasterKeys keys = _fromMemoryStorage(password, _massterKey!);
    final Bip32Base bip32 = newKey.toBip32();
    final checkshum = bip32.publicKey.fingerPrint.toHex();
    final publicKey = bip32.publicKey.toHex();
    if (checkshum != newKey.checksum || newKey.publicKey != publicKey) {
      throw WalletExceptionConst.invalidAccountDetails;
    }

    if (keys.customKeys.contains(newKey)) {
      throw WalletExceptionConst.keyAlreadyExist;
    }
    return keys.addKey(newKey);
  }

  WalletMasterKeys _removeCustomKey(
      EncryptedCustomKey importedKey, List<int> password) {
    final WalletMasterKeys keys = _fromMemoryStorage(password, _massterKey!);
    final newWallet = keys.removeKey(importedKey.id);
    return newWallet;
  }

  Future<void> _setupMasterKey(
    String encryptedWallet,
    List<int> password,
  ) async {
    _massterKey = await _readMasterKey(encryptedWallet, password);
  }
}
