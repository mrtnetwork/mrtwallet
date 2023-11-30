part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin MasterKeyImpl on WalletCryptoImpl {
  EncryptedMasterKey? _massterKey;
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
                created: e.created))
            .toList());
  }

  List<int> _getPrivateKey(
      List<int> password, AddressDerivationIndex keyIndex) {
    switch (keyIndex.runtimeType) {
      case Bip32AddressIndex:
      case ImportedAddressIndex:
        final WalletMasterKeys walletMasterKeys =
            _fromMemoryStorage(password, _massterKey!);
        final prv = _getBip32FromKeyIndex(keyIndex, walletMasterKeys);
        return prv.privateKey.raw;
      default:
        throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
  }

  bool _validateBcakupAccounts(WalletBackup backup, CryptoAddress address) {
    if (address.keyIndex is ImportedAddressIndex ||
        address.keyIndex is Bip32AddressIndex) {
      final bip32 = _getBip32FromKeyIndex(address.keyIndex, backup.masterKeys);
      if (!address.signers.contains(bip32.publicKey.toHex())) {
        return false;
      }
    } else {
      return _validateMultiSigAccount(
          backup.masterKeys, address as IBitcoinMultiSigAddress);
    }
    return true;
  }

  bool _validateMultiSigAccount(
      WalletMasterKeys masterKey, IBitcoinMultiSigAddress address) {
    for (final i in address.multiSignatureAddress.signers) {
      final bip32 = _getBip32FromKeyIndex(i.keyIndex, masterKey);
      if (!address.signers.contains(bip32.publicKey.toHex())) {
        return false;
      }
    }
    return true;
  }

  Bip32Slip10Secp256k1 _getBip32FromKeyIndex(
      AddressDerivationIndex keyIndex, WalletMasterKeys masterKey) {
    if (keyIndex is MultiSigAddressIndex) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    if (keyIndex is ImportedAddressIndex) {
      final key = masterKey.getKeyById(keyIndex.accountId)!;
      final Bip32Slip10Secp256k1 bip32 =
          Bip32Slip10Secp256k1.fromExtendedKey(key.extendedPrivateKey);
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
    Bip32Slip10Secp256k1 bip32;
    if (keyIndex is ImportedAddressIndex) {
      final WalletCustomKeys key = keys.customKeys
          .firstWhere((element) => element.checksum == keyIndex.accountId);
      bip32 = Bip32Slip10Secp256k1.fromExtendedKey(key.extendedPrivateKey);
    } else {
      bip32 = Bip32Slip10Secp256k1.fromSeed(keys.seed);
    }
    final Bip32Slip10Secp256k1 derive = keyIndex.derive(bip32);
    final publicKey = derive.publicKey.compressed;
    return publicKey;
  }

  WalletMasterKeys _importCustomKey(
      WalletCustomKeys newKey, List<int> password) {
    final WalletMasterKeys keys = _fromMemoryStorage(password, _massterKey!);
    final bip32 =
        Bip32Slip10Secp256k1.fromExtendedKey(newKey.extendedPrivateKey);
    final checkshum = bip32.publicKey.fingerPrint.toHex();
    final publicKey = bip32.publicKey.toHex();
    if (checkshum != newKey.checksum || newKey.publicKey != publicKey) {
      throw WalletExceptionConst.invalidAccountDetails;
    }

    if (keys.customKeys.contains(newKey)) {
      throw WalletExceptionConst.addressAlreadyExist;
    }
    return keys.addKey(newKey);
  }

  Future<void> _setupMasterKey(
    String encryptedWallet,
    List<int> password,
  ) async {
    _massterKey = await _readMasterKey(encryptedWallet, password);
  }
}
