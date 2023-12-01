part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

// ignore: library_private_types_in_public_api
mixin WalletStatusImpl on _WalletCore {
  bool _inProgress = false;
  bool get inProgress => _inProgress;
  WalletStatus _status = WalletStatus.setup;
  WalletStatus get status => _status;
  bool get walletIsLock => _status == WalletStatus.lock;
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
    List<int> wp;
    List<int> walletChecksum;
    if (_password != null && _checksum != null) {
      wp = _toWalletPassword(password, _checksum!);
      walletChecksum = List.unmodifiable(_checksum!);
      if (!bytesEqual(wp, _password)) {
        throw WalletExceptionConst.incorrectPassword;
      }
    } else {
      final encrypWallet = await _readWallet();
      walletChecksum = BytesUtils.fromHexString(encrypWallet!.$2);
      wp = _toWalletPassword(password, walletChecksum);
      await _setupMasterKey(encrypWallet.$1, wp);
      _setStorageCheckSum(_massterKey!.checksum);
    }
    await _setupNetwork();
    await _readAccounts();

    _password = wp;
    _checksum = walletChecksum;
  }

  Future<void> _deriveNewAccount(NewAccountParams newAccountParams) async {
    if (!network.coins.contains(newAccountParams.coin)) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    if (newAccountParams is BitcoinMultiSigNewAddressParams) {
      await _addNewAccountToNetwork(newAccountParams, const []);
      return;
    }
    final publicKey = _deriveNewAddress(newAccountParams, _password!);
    await _addNewAccountToNetwork(newAccountParams, publicKey);
  }

  Future<void> _importNewKey(WalletCustomKeys newKey, String password) async {
    final pw = _validatePassword(password);
    final key = _importCustomKey(newKey, pw);
    final encrypt = await _forStorage(key, pw);
    await _setupMasterKey(encrypt, pw);
    await _writeWallet(encrypt, _toStorageChecksum());
  }

  Future<void> _removeKey(EncryptedCustomKey newKey, String password) async {
    final pw = _validatePassword(password);
    if (!_massterKey!.customKeys.contains(newKey)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    final key = _removeCustomKey(newKey, pw);
    final encrypt = await _forStorage(key, pw);
    await _setupMasterKey(encrypt, pw);
    await _clenCustomKeysAccount(_account!, _massterKey!.customKeys);
    await _writeWallet(encrypt, _toStorageChecksum());
  }

  Future<void> _setup(WalletMasterKeys mnemonic, String password) async {
    final checkshum = QuickCrypto.generateRandom(16);
    final pw = _toWalletPassword(password, checkshum);
    final data = await _forStorage(mnemonic, pw);
    await _writeWallet(data, BytesUtils.toHexString(checkshum));
    await _login(password);
  }

  Future<void> _setupBackup(WalletBackup backup, String password) async {
    try {
      BlockchainUtils.validateMnemonic(backup.masterKeys.mnemonic.toStr());
      for (final i in backup.accounts) {
        for (final b in i.addresses) {
          final validate = _validateBcakupAccounts(backup, b);
          if (!validate) {
            throw WalletExceptionConst.invalidBackup;
          }
        }
      }
      await _setup(backup.masterKeys, password);
      for (final i in backup.accounts) {
        await _saveAccount(i);
      }
      await _login(password);
    } catch (e) {
      await _cleanWallet();
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
    if (!bytesEqual(toPw, _password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    return toPw;
  }

  Future<BtcTransaction> _signBitcoinTransaction(
      {required BitcoinTransactionBuilder builder,
      required List<Bip32AddressCore> accouts,
      required String password}) async {
    final toPasasword = _validatePassword(password);
    return _signBitcoin(
        password: toPasasword, builder: builder, accouts: accouts);
  }

  Future<String> restoreBackup(
    String password,
    String backup,
    SecretWalletEncoding encoding,
  ) async {
    return SecretStorageCompute.decrypt(backup, password, encoding: encoding);
  }

  Future<void> _changePassword(String password, String newPassword) async {
    _validatePassword(password);
    if (!AppStringUtility.isStrongPassword(newPassword)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final encrypWallet = await _readWallet();
    final walletKey = await _fromStroage(encrypWallet!.$1, _password!);
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
    final mn = await _fromStroage(encrypWallet!.$1, pw);
    final updateKeys = mn.updateSetting(setting);
    final data = await _forStorage(updateKeys, pw);
    await _writeWallet(data, _toStorageChecksum());
    _massterKey = _massterKey!.updateSetting(setting);
  }

  Future<void> _eraseWallet(String password) async {
    // _validatePassword(password);
    await _cleanWallet();
  }

  Future<void> _cleanWallet() async {
    _password = null;
    _account = null;
    _massterKey = null;
    _account = null;
    await _deleteAll();
    await deleteAll();
  }

  void _logout() {
    _password = null;
    _status = WalletStatus.lock;
    _account = null;
  }

  Future<String> _getWalletBackup(String password,
      {SecretWalletEncoding encoding = SecretWalletEncoding.cbor}) async {
    final pw = _validatePassword(password);
    final encrypWallet = await _readWallet();
    final masterKeys = await _fromStroage(encrypWallet!.$1, pw);
    final accounts = await _readAllAccounts();
    final backup = WalletBackup(masterKeys: masterKeys, accounts: accounts);
    return SecretStorageCompute.encrypt(backup.toCbor().toCborHex(), password,
        encoding: encoding);
  }
}
