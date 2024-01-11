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
    final mn = await _fromStroage(encryptedWallet, password);
    final bip32 = Bip32Slip10Secp256k1.fromSeed(mn.seed);
    final encrypt = _toMemoryStorage(password, mn.toCbor().encode());
    return EncryptedMasterKey(
        checksum: bip32.publicKey.fingerPrint.toHex(),
        keyBytes: encrypt,
        setting: mn.setting,
        customKeys: mn.customKeys
            .map((e) => EncryptedCustomKey(
                publicKey: e.publicKey,
                type: e.type,
                id: e.checksum,
                created: e.created,
                name: e.name))
            .toList());
  }

  Bip32Base _getPrivateKey(
      List<int> password, AddressDerivationIndex keyIndex) {
    try {
      switch (keyIndex.runtimeType) {
        case Bip32AddressIndex:
        case ImportedAddressIndex:
          final WalletMasterKeys walletMasterKeys =
              _fromMemoryStorage(password, _massterKey!);

          return _getBip32FromKeyIndex(keyIndex, walletMasterKeys);
        default:
          throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
    } catch (e) {
      rethrow;
    }
  }

  bool _validateBcakupAccounts(
      WalletMasterKeys masterKey, CryptoAccountAddress address) {
    if (!address.multiSigAccount) {
      final bip32 = _getBip32FromKeyIndex(address.keyIndex, masterKey);
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
      AddressDerivationIndex keyIndex, WalletMasterKeys masterKey) {
    if (keyIndex is MultiSigAddressIndex) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    if (keyIndex is ImportedAddressIndex) {
      final key = masterKey.getKeyById(keyIndex.accountId)!;
      final Bip32Base bip32 = key.toBip32();
      return keyIndex.derive(bip32);
    }
    final Bip32Slip10Secp256k1 bip32 =
        Bip32Slip10Secp256k1.fromSeed(masterKey.seed);
    return keyIndex.derive(bip32);
  }

  Future<Mnemonic> _readMnemonic(
    String encryptedWallet,
    List<int> password,
  ) async {
    final mn = await _fromStroage(encryptedWallet, password);
    return mn.mnemonic;
  }

  List<int> _deriveNewAddress(NewAccountParams params, List<int> password) {
    final WalletMasterKeys keys = _fromMemoryStorage(password, _massterKey!);
    final keyIndex = params.deriveIndex;
    Bip32Base bip32;
    if (keyIndex is ImportedAddressIndex) {
      final WalletCustomKeys key = keys.customKeys
          .firstWhere((element) => element.checksum == keyIndex.accountId);
      bip32 = key.toBip32();
    } else {
      bip32 = Bip32Slip10Secp256k1.fromSeed(keys.seed);
    }
    final Bip32Base derive = keyIndex.derive(bip32);
    final publicKey = derive.publicKey.compressed;
    return publicKey;
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
