part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

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
                coin: e.coin,
                id: e.checksum,
                created: e.created,
                name: e.name,
                keyType: e.keyType))
            .toList());
  }

  Bip32Base _getPrivateKey(List<int> password, AddressDerivationIndex keyIndex,
      {SeedTypes seedType = SeedTypes.bip39,
      Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (keyIndex.derivationType.isMultiSig) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    final WalletMasterKeys walletMasterKeys =
        _fromMemoryStorage(password, _massterKey!);

    return walletMasterKeys.toKey(keyIndex, maxLevel: maxLevel);
  }

  AccessPrivateKeyResponse _getImportedKeyFromId(
      List<int> password, String keyId) {
    final WalletMasterKeys walletMasterKeys =
        _fromMemoryStorage(password, _massterKey!);
    final key = walletMasterKeys.getKeyById(keyId);
    if (key == null) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    return AccessPrivateKeyResponse.fromBip32(
        account: key.toKey(null), coin: key.coin, keyName: keyId);
  }

  Future<Mnemonic> _readMnemonic(
    String encryptedWallet,
    List<int> password,
  ) async {
    final mn = await _masterKeyFromStorage(encryptedWallet, password);
    return mn.mnemonic;
  }

  CardanoNewAddressParams _deriveCardanoNewAddress(
      CardanoNewAddressParams params, WalletMasterKeys keys) {
    final bool byronLegacy = params.coin.proposal == CustomProposal.cip0019;
    final bip = keys.toKey(params.deriveIndex,
        maxLevel: byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex);
    final CardanoAddrDetails addrDetails;
    switch (params.addressType) {
      case ADAAddressType.base:
        final stake = keys.toKey(params.rewardKeyIndex!);
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.publicKey.compressed,
            stakePubkey: stake.publicKey.compressed,
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.enterprise:
      case ADAAddressType.reward:
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.publicKey.compressed,
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.byron:
        if (byronLegacy) {
          try {
            final legacy = CardanoByronLegacy.fromBip32(bip);
            Bip32Base pubkey = legacy.bip32;
            if (params.deriveIndex.hdPath != null) {
              pubkey = legacy.bip32.derivePath(params.deriveIndex.hdPath!);
            }
            addrDetails = CardanoAddrDetails.byron(
                publicKey: pubkey.publicKey.compressed,
                chainCode: pubkey.publicKey.chainCode.toBytes(),
                seedGeneration: params.deriveIndex.seedGeneration,
                hdPathKey: params.customHdPathKey ?? legacy.hdPathKey,
                hdPath: params.customHdPath ?? params.deriveIndex.hdPath);

            break;
          } catch (e) {
            rethrow;
          }
        }

        addrDetails = CardanoAddrDetails.byron(
            publicKey: bip.publicKey.compressed,
            chainCode: bip.chainCode.toBytes(),
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      default:
        throw UnimplementedError();
    }
    return params.copyWith(addressDetails: addrDetails);
  }

  WalletMasterKeys _importCustomKey(
      ImportedKeyStorage newKey, List<int> password) {
    final WalletMasterKeys keys = _fromMemoryStorage(password, _massterKey!);
    final Bip32Base bip32 = newKey.toKey(null);
    final checkshum = BlockchainUtils.createCustomKeyChecksum(bip32);
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
