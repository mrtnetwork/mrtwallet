part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

abstract class _WalletCore extends StateController
    with
        NativeSecureStorageImpl,
        WalletStorageImpl,
        WalletCryptoImpl,
        MasterKeyImpl,
        NetworkApiProviderImpl,
        WalletNetworkImpl,
        Signer {}

abstract class WalletCore extends _WalletCore with WalletStatusImpl {
  WalletCore(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;

  final _lock = SynchronizedLock();

  Future<MethodResult<void>> setup(
      WalletMasterKeys mnemonic, String password) async {
    try {
      final result = await _callSynchronized(
          () async => await _setup(mnemonic, password),
          conditionStatus: WalletStatus.setup,
          onSuccessStatus: WalletStatus.lock);

      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> setupBackup(
      WalletBackup backup, String password) async {
    try {
      final result = await _callSynchronized(
          () async => await _setupBackup(backup, password),
          conditionStatus: WalletStatus.setup,
          onSuccessStatus: WalletStatus.lock);

      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> login(String password) async {
    try {
      final result = await _callSynchronized(() async => await _login(password),
          conditionStatus: WalletStatus.lock,
          onSuccessStatus: WalletStatus.unlock);

      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> changePassword(
      String password, String newPassword) async {
    try {
      final result = await _callSynchronized(
          () async => await _changePassword(password, newPassword),
          conditionStatus: WalletStatus.unlock,
          onSuccessStatus: WalletStatus.lock);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> updateWlletSetting(
      String password, WalletSetting setting) async {
    try {
      final result = await _callSynchronized(
          () async => await _updateSetting(password, setting),
          conditionStatus: WalletStatus.unlock);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> deriveNewAccount(
      NewAccountParams newAccountParams) async {
    try {
      final result = await _callSynchronized(
          () async => await _deriveNewAccount(newAccountParams),
          conditionStatus: WalletStatus.unlock);

      return result;
    } finally {
      notify();
      if (walletIsUnlock) {
        updateBalance();
      }
    }
  }

  Future<MethodResult<void>> importAccount(
      WalletCustomKeys newAccountParams, String password) async {
    final result = await _callSynchronized(
        () async => await _importNewKey(newAccountParams, password),
        conditionStatus: WalletStatus.unlock);
    return result;
  }

  Future<MethodResult<void>> removeAccount(CryptoAddress account) async {
    try {
      final result = await _callSynchronized(
          () async => await _removeAccount(account),
          conditionStatus: WalletStatus.unlock);

      return result;
    } finally {
      notify();
    }
  }

  Future<void> switchNetwork(AppNetworkImpl? network) async {
    if (network == null || network == _network) return;
    pageStatusHandler.progressText("switching_network".tr);
    await _callSynchronized(() async => await _switchNetwork(network),
        conditionStatus: WalletStatus.unlock);
    _backToHome();
    pageStatusHandler.success();
  }

  Future<void> changeProvider(ApiProviderService? provider) async {
    if (provider == null) return;
    await _callSynchronized(() async => _changeNetworkApiProvider(provider),
        conditionStatus: WalletStatus.unlock, delay: null);
    notify();
  }

  Future<MethodResult<String>> accsess(
      WalletAccsessType accsessType, String password,
      {CryptoAddress? account}) async {
    final result = await _callSynchronized(() async {
      if (accsessType == WalletAccsessType.privateKey && account == null) {
        throw WalletException.invalidArgruments(["CryptoAddress", "null"]);
      }

      if (accsessType == WalletAccsessType.privateKey) {
        final privateKey =
            _getPrivateKey(_validatePassword(password), account!.keyIndex);
        return BytesUtils.toHexString(privateKey);
      } else if (accsessType == WalletAccsessType.seed) {
        final mnemoic = await _unlockMnemonic(password);
        return mnemoic.toStr();
      } else {
        _validatePassword(password);
        return "";
      }
    }, conditionStatus: WalletStatus.unlock);
    return result;
  }

  Future<MethodResult<String>?> generateBackup(
      String data, String password, SecretWalletEncoding encoding) async {
    final result = await _callSynchronized(
        () async => await _generateBackup(data, password, encoding),
        conditionStatus: WalletStatus.unlock);
    return result;
  }

  Future<MethodResult<String>?> generateWalletBackup(
      String password, SecretWalletEncoding encoding) async {
    final result = await _callSynchronized(() async {
      return await _getWalletBackup(password, encoding: encoding);
    }, conditionStatus: WalletStatus.unlock);
    return result;
  }

  Future<void> switchAccount(CryptoAddress? account) async {
    if (account == null || account == _account?.address) return;
    pageStatusHandler.progressText("switching_account".tr);
    await _callSynchronized(() async => _switchAccount(account),
        conditionStatus: WalletStatus.unlock);
    pageStatusHandler.success();
  }

  Future<MethodResult<void>> eraseWallet(String password) async {
    try {
      await _cleanWallet();

      final result = await _callSynchronized(() async => _eraseWallet(password),
          conditionStatus: WalletStatus.unlock,
          onSuccessStatus: WalletStatus.setup);
      return result;
    } finally {
      _backToHome();
      notify();
    }
  }

  void lock() async {
    try {
      await _callSynchronized(() async {
        _logout();
      },
          conditionStatus: WalletStatus.unlock,
          onSuccessStatus: WalletStatus.lock,
          delay: null);
    } finally {
      _backToHome();
      _logout();
      notify();
    }
  }

  Future<String> _getPassword(List<Bip32AddressCore> accouts) async {
    bool inRetry = false;

    final pw =
        await _navigatorKey.currentContext?.openSliverBottomSheet<String>(
            WalletSigningPassword(
              onPasswordValidator: (p0) async {
                try {
                  if (inRetry) {
                    throw WalletExceptionConst.toManyRequests;
                  }
                  inRetry = true;
                  await Future.delayed(AppGlobalConst.oneSecoundDuration);
                  _validatePassword(p0);
                  return true;
                } finally {
                  inRetry = false;
                }
              },
              signers: accouts,
            ),
            "sign_transaction".tr);
    if (pw == null) {
      throw WalletExceptionConst.rejectSigning;
    }
    return pw;
  }

  Future<MethodResult<BtcTransaction>> signBitcoinTransaction(
      {required BitcoinTransactionBuilder builder,
      required List<Bip32AddressCore> accouts}) async {
    final result = await _callSynchronized(() async {
      final password = await _getPassword(accouts);
      return await _signBitcoinTransaction(
          builder: builder, accouts: accouts, password: password);
    }, conditionStatus: WalletStatus.unlock);
    return result;
  }

  @override
  Future<void> _initWallet() async {
    await _lock.synchronized(() async => await super._initWallet());
    pageStatusHandler.success();
    notify();
  }

  Future<MethodResult<T>> _callSynchronized<T>(Future<T> Function() t,
      {required WalletStatus conditionStatus,
      WalletStatus? onSuccessStatus,
      Duration? delay = AppGlobalConst.oneSecoundDuration}) async {
    return await _lock.synchronized(() async {
      final result = await MethodCaller.call(() async {
        if (_status != conditionStatus || inProgress) {
          throw WalletExceptionConst.incorrectStatus;
        }
        _inProgress = true;
        return await t();
      }, delay: delay);
      if (result.hasResult) {
        _status = onSuccessStatus ?? conditionStatus;
      }
      _inProgress = false;
      return result;
    });
  }

  Future<void> updateBalance() async {
    await MethodCaller.call(() async {
      await _updateAccountBalance(_account);
    });
  }

  Future<void> updateAccountBalance() async {
    await MethodCaller.call(() async {
      await _updateAccountsBalance(_account);
    });
  }

  List<EncryptedCustomKey> getNetworkImportedKeys() {
    if (walletIsUnlock) {
      final EllipticCurveTypes keyCurveMode = haveAddress
          ? networkAccount.address.coin.conf.type
          : network.coins.first.conf.type;
      return _massterKey!.customKeys
          .where((element) => element.type == keyCurveMode)
          .toList();
    }
    return [];
  }

  void _backToHome() {
    _navigatorKey.currentContext?.popToHome();
  }

  void _onTimer() {
    try {
      _status = WalletStatus.lock;
      _backToHome();
    } finally {
      notify();
    }
  }

  late final LifeCycleTracker _lifeCycleTracker = LifeCycleTracker(
    _onTimer,
    () {
      if (walletIsUnlock) return _massterKey?.setting.lockTime;
      return null;
    },
  );

  @override
  void init() {
    _initWallet();
    _lifeCycleTracker.init();
    super.init();
  }

  @override
  void close() {
    _lifeCycleTracker.dispose();
    super.close();
  }
}
