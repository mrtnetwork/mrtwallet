part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin WalletStatusImpl on _WalletCore {
  bool _inProgress = false;
  bool get inProgress => _inProgress;
  WalletStatus _status = WalletStatus.setup;
  WalletStatus get status => _status;
  bool get walletIsLock => _status == WalletStatus.lock;
  @override
  bool get walletIsUnlock => _status == WalletStatus.unlock;
  bool get walletInSetup => _status == WalletStatus.setup;
  GlobalKey<PageProgressState> get pageStatusHandler;
  List<int>? _password;
  List<int>? _checksum;

  String _toStorageChecksum() {
    return BytesUtils.toHexString(_checksum!);
  }

  Future<void> _initWallet() async {
    final walletIsSetup = await _readWallet();

    if (walletIsSetup != null) {
      _status = WalletStatus.lock;
    } else {
      _status = WalletStatus.setup;
    }
  }

  Future<void> _login(String password) async {
    final encrypWallet = await _readWallet();
    List<int> walletChecksum = BytesUtils.fromHexString(encrypWallet!.$2);
    List<int> wp = _toWalletPassword(password, walletChecksum);
    await _setupMasterKey(encrypWallet.$1, wp);
    _setStorageCheckSum(_massterKey!.checksum);
    await _setupNetwork();
    _password = List<int>.unmodifiable(wp);
    _checksum = List<int>.unmodifiable(walletChecksum);
  }

  Future<CryptoAccountAddress> _deriveNewAccount(
      NewAccountParams newAccountParams) async {
    if (newAccountParams.isMultiSig) {
      return await _addNewAccountToNetwork(newAccountParams, const []);
    }

    if (!network.coins.contains(newAccountParams.coin)) {
      throw WalletExceptionConst.incorrectNetwork;
    }

    WalletMasterKeys keys = _fromMemoryStorage(_password!, _massterKey!);
    final int derivedKeys = keys.derivedKeys.length;
    final CryptoAccountAddress newAccount;

    if (newAccountParams is CardanoNewAddressParams) {
      final cardanoDeriveResult =
          _deriveCardanoNewAddress(newAccountParams, keys);
      newAccount = await _addNewAccountToNetwork(
        cardanoDeriveResult,
        cardanoDeriveResult.addressDetails!.publicKey,
      );
    } else {
      try {
        final derivedResult = keys.toKey(newAccountParams.deriveIndex);
        newAccount = await _addNewAccountToNetwork(
            newAccountParams, derivedResult.publicKey.compressed);
      } catch (e) {
        rethrow;
      }
    }
    if (derivedKeys != keys.derivedKeys.length) {
      await _updateWallet(keys);
    }
    return newAccount;
  }

  Future<void> _importNewKey(WalletCustomKeys newKey, String password) async {
    final pw = _validatePassword(password);
    final key = _importCustomKey(newKey, pw);
    final encrypt = await _forStorage(key, pw);
    await _setupMasterKey(encrypt, pw);
    await _writeWallet(encrypt, _toStorageChecksum());
  }

  Future<void> _updateWallet(WalletMasterKeys newKey,
      {String? password}) async {
    final pw = password == null ? _password! : _validatePassword(password);
    final encrypt = await _forStorage(newKey, pw);
    await _setupMasterKey(encrypt, pw);
    await _writeWallet(encrypt, _toStorageChecksum());
  }

  Future<void> _removeKey(EncryptedCustomKey newKey, String password) async {
    final pw = _validatePassword(password);
    if (!_massterKey!.customKeys.contains(newKey)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    List<EncryptedCustomKey> keys = List.unmodifiable(
        _massterKey!.customKeys.where((element) => element != newKey).toList());
    for (final i in _appChains.networks.values) {
      await _cleanUpAccount(account: i.account, existKeys: keys);
    }
    final key = _removeCustomKey(newKey, pw);
    final encrypt = await _forStorage(key, pw);
    await _setupMasterKey(encrypt, pw);
    await _writeWallet(encrypt, _toStorageChecksum());
  }

  Future<void> _setup(WalletMasterKeys mnemonic, String password) async {
    final checkshum = QuickCrypto.generateRandom(16);
    final pw = _toWalletPassword(password, checkshum);
    final data = await _forStorage(mnemonic, pw);
    await _writeWallet(data, BytesUtils.toHexString(checkshum));
    await _login(password);
  }

  Future<void> _setupBackup(WalletBackupCore backup, String password) async {
    try {
      backup as WalletBackupV2;
      BlockchainUtils.validateMnemonic(backup.masterKeys.mnemonic.toStr());

      await _setup(backup.masterKeys, password);
      for (final i in backup.chains) {
        await _saveAccount(i);
      }
      await _login(password);
    } catch (e) {
      await _clearWallet();
      throw WalletExceptionConst.invalidBackup;
    }
  }

  Future<Mnemonic> _unlockMnemonic(String password) async {
    if (!AppStringUtility.isStrongPassword(password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final pw = _validatePassword(password);
    final wallet = await _readWallet();
    return _readMnemonic(wallet!.$1, pw);
  }

  Future<String> _generateBackup(String dataToEncrypt, String password,
      SecretWalletEncoding encoding) async {
    _validatePassword(password);
    return SecretStorageCompute.encrypt(dataToEncrypt, password,
        encoding: encoding);
  }

  List<int> _validatePassword(String password) {
    if (!walletIsUnlock) {
      throw WalletExceptionConst.walletIsLocked;
    }

    final toPw = _toWalletPassword(password, _checksum!);
    if (!BytesUtils.bytesEqual(toPw, _password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    return toPw;
  }

  Future<List<int>> restoreBackup(
    String password,
    String backup,
    SecretWalletEncoding encoding,
  ) async {
    return SecretStorageCompute.decrypt(backup, password, encoding: encoding);
  }

  Future<void> _changePassword(String password, String newPassword) async {
    final pw = _validatePassword(password);
    if (!AppStringUtility.isStrongPassword(newPassword)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final encrypWallet = await _readWallet();
    final walletKey = await _masterKeyFromStorage(encrypWallet!.$1, pw);
    final newCheckSum = QuickCrypto.generateRandom(16);
    final nPassword = _toWalletPassword(newPassword, newCheckSum);
    final data = await _forStorage(walletKey, nPassword);
    await _writeWallet(data, BytesUtils.toHexString(newCheckSum));
    _password = null;
    _checksum = null;
  }

  Future<void> _updateSetting(String password, WalletSetting setting) async {
    final pw = _validatePassword(password);
    final encrypWallet = await _readWallet();
    final mn = await _masterKeyFromStorage(encrypWallet!.$1, pw);
    final updateKeys = mn.updateSetting(setting);
    final data = await _forStorage(updateKeys, pw);
    await _writeWallet(data, _toStorageChecksum());
    _massterKey = _massterKey!.updateSetting(setting);
  }

  Future<void> _eraseWallet(String password) async {
    _validatePassword(password);
    await _clearWallet();
  }

  Future<void> _clearWallet() async {
    _cleanWallet();
    await _deleteAll();
    await deleteAll();
  }

  void _logout() {
    _cleanWallet();
    _status = WalletStatus.lock;
  }

  void _cleanWallet() {
    _password = null;
    _checksum = null;
    _walletChecksum = null;
    _massterKey = null;
  }

  Future<String> _getWalletBackupV2(String password,
      {SecretWalletEncoding encoding = SecretWalletEncoding.cbor}) async {
    final pw = _validatePassword(password);
    final encrypWallet = await _readWallet();
    final masterKeys = await _masterKeyFromStorage(encrypWallet!.$1, pw);
    final backup = WalletBackupV2(
      masterKeys: masterKeys,
      chains: _appChains.networks.values.toList(),
    );
    return SecretStorageCompute.encrypt(backup.toCbor().toCborHex(), password,
        encoding: encoding);
  }

  Future<List<AccessKeyResponse>> _accsess(
      WalletAccsessType accsessType, String password,
      {CryptoAccountAddress? account, String? accountId}) async {
    if (accsessType.isAccsessKey && account == null && accountId == null) {
      throw WalletException.invalidArgruments(["CryptoAccountAddress", "null"]);
    }

    if (accsessType.isAccsessKey) {
      if (account != null) {
        final accountKeys = account.keyIndexes.map((e) {
          final key = _getPrivateKey(_validatePassword(password), e);
          return AccessPrivateKeyResponse.fromBip32(
              account: key,
              coin: account.keyIndex.currencyCoin,
              keyName: e.name);
        }).toList();
        _getPrivateKey(_validatePassword(password), account.keyIndex);
        return accountKeys;
      } else {
        final importedKey =
            _getImportedKeyFromId(_validatePassword(password), accountId!);
        return [importedKey];
      }
    } else if (accsessType == WalletAccsessType.seed) {
      final mnemoic = await _unlockMnemonic(password);
      return [AccessMnemonicResponse(mnemoic)];
    } else {
      _validatePassword(password);
      return [AccessFakeResponse()];
    }
  }

  List<AccessPubliKeyResponse> _getAccountPubKys(
      {required CryptoAccountAddress account}) {
    return account.keyIndexes.map((e) {
      final key = _getPrivateKey(_password!, e);
      return AccessPubliKeyResponse.fromBip32(
          account: key, coin: account.keyIndex.currencyCoin, keyName: e.name);
    }).toList();
  }
}
