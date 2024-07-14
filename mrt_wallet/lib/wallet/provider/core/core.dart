part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

abstract class WalletStateController extends StateController {
  void addWalletListener(OnWalletEvent listener);
  void removeWalletListener(OnWalletEvent listener);
  List<String> coinIds();
}

abstract class _WalletCore extends WalletStateController
    with WalletStorageWriter, WalletsStoragesManger {}

abstract class WalletCore extends _WalletCore
    with WalletsManager, BaseRepository, WalletsListener {
  WalletCore(this._navigatorKey);
  final GlobalKey<NavigatorState> _navigatorKey;
  final _lock = SynchronizedLock();

  GlobalKey<PageProgressBaseState> get pageStatusHandler;

  ChainHandler get chain => _controller._appChains.chain;
  WalletNetwork get network => chain.network;
  HDWallet get wallet => _controller._wallet;
  List<HDWallet> get wallets => _wallets._wallets.values.toList();
  String? get defaultWalletId => _wallets._defaultWallet;

  Future<MethodResult<T>> _callSynchronized<T>(
    Future<T> Function() t, {
    required bool conditionStatus,
    Duration? delay = APPConst.oneSecoundDuration,
    Future<void> Function()? onWrongStatus,
  }) async {
    bool emeitListeners = false;
    try {
      return await _lock.synchronized(() async {
        final status =
            WalletEventStaus.fromWalletStatus(_homePageStatus, isOpen);
        final result = await MethodUtils.call(() async {
          if (!conditionStatus) {
            if (onWrongStatus != null) {
              await onWrongStatus();
            }
            if (!conditionStatus) {
              throw WalletExceptionConst.incorrectStatus;
            }
          }
          return await t();
        }, delay: delay);
        final after =
            WalletEventStaus.fromWalletStatus(_homePageStatus, isOpen);
        if (status != after) {
          emeitListeners = true;
        }
        return result;
      });
    } finally {
      if (emeitListeners) {
        emitWalletListeners();
      }
    }
  }

  @override
  List<String> coinIds() => homePageStatus.isReady ? _controller.coinIds() : [];

  Future<MethodResult<void>> setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    try {
      pageStatusHandler.progressText("launch_the_wallet".tr);
      final result = await _callSynchronized(() async {
        await _setup(
            hdWallet: hdWallet, password: password, walletInfos: walletInfos);
      }, conditionStatus: true);
      if (!result.hasError) {
        _backToHome();
      }
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> setupBackup(
      {required WalletRestoreV2 backup,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    try {
      pageStatusHandler.progressText("launch_the_wallet".tr);
      final result = await _callSynchronized(() async {
        await _setup(
            hdWallet: backup.wallet,
            password: password,
            walletInfos: walletInfos,
            chains: backup.chains);
      }, conditionStatus: true);
      if (!result.hasError) {
        _backToHome();
      }
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<void> _onWalletLocked(String password) async {
    if (!homePageStatus.isReady || _isUnlock) return;
    await _controller._login(password);
  }

  Future<MethodResult<void>> login(String password) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._login(password),
          conditionStatus: _isLock);

      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> changePassword(
      String password, String newPassword) async {
    try {
      pageStatusHandler.progressText("changing_password".tr);
      final result = await _callSynchronized(() async {
        await _controller._changePassword(password, newPassword);
      }, conditionStatus: _isUnlock);
      if (result.hasResult) {
        _backToHome();
      }
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> updateWalletInfos(
      {required WalletUpdateInfosData walletInfos,
      required String password}) async {
    try {
      pageStatusHandler.progressText("updating".tr);
      final result = await _callSynchronized(() async {
        return await _controller._updateWalletInfos(
            password: password, walletInfos: walletInfos);
      }, conditionStatus: _isUnlock);
      if (result.hasResult && _controller.isLock) {
        _backToHome();
      }
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<CryptoAddress>> deriveNewAccount(
      NewAccountParams newAccountParams) async {
    try {
      pageStatusHandler.progressText("setup_new_account_pls_wait".tr);
      final result = await _callSynchronized(
          () async => await _controller._deriveNewAccount(newAccountParams),
          conditionStatus: _isUnlock,
          delay: APPConst.milliseconds100);
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> importAccount(
      ImportedKeyStorage newAccountParams, String password) async {
    try {
      final result = await _callSynchronized(
          () async =>
              await _controller._importNewKey(newAccountParams, password),
          conditionStatus: _isUnlock);
      return result;
    } finally {
      notify();
    }
  }

  Future<void> switchWallet(HDWallet? wallet) async {
    if (wallet == null) return;
    pageStatusHandler.progressText("switching_wallet".tr);
    await _callSynchronized(() async {
      await _switchWallet(wallet);
    }, conditionStatus: homePageStatus.isReady);
    pageStatusHandler.success();
  }

  Future<MethodResult<void>> addNewContact(ContactCore newContact) async {
    final result = await _callSynchronized(
        () async => await _controller._addNewContact(newContact),
        conditionStatus: isOpen);
    return result;
  }

  Future<MethodResult<void>> addNewToken(
      TokenCore token, CryptoAddress address) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._addNewToken(token, address),
          conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> removeToken(
      TokenCore token, CryptoAddress address) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._removeToken(token, address),
          conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> updateToken({
    required TokenCore<dynamic> token,
    required Token updatedToken,
    required CryptoAddress address,
  }) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._updateToken(
              token: token, address: address, updatedToken: updatedToken),
          conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> addNewNFT(
      NFTCore nft, CryptoAddress address) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._addNewNFT(nft, address),
          conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> removeNFT(
      NFTCore nft, CryptoAddress address) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._removeNFT(nft, address),
          conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> setupAccountName(
      String? name, CryptoAddress address) async {
    try {
      final result = await _callSynchronized(() async {
        if (name == null || !APPConst.accountNameRegExp.hasMatch(name)) {
          return;
        }
        await _controller._setAccountName(
            name.trim().isEmpty ? null : name, address);
      }, conditionStatus: isOpen);
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<List<EncryptedCustomKey>>> getImportedAccounts(
      String password) {
    final result = _callSynchronized(() async {
      return _controller._getImportedAccounts(password);
    }, conditionStatus: _isUnlock);
    return result;
  }

  List<WalletNetwork> networks() {
    if (isOpen) {
      return _controller._appChains.networks();
    }
    return [];
  }

  List<ChainHandler> getChains() {
    if (isOpen) {
      return _controller._appChains.chains();
    }
    return [];
  }

  Future<MethodResult<void>> removeImportedKey(
      EncryptedCustomKey key, String password) {
    try {
      pageStatusHandler.progressText("removing_key_pls_wait".tr);
      final result = _callSynchronized(() async {
        return await _controller._removeKey(key, password);
      }, conditionStatus: _isUnlock);
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<void>> removeAccount(CryptoAddress account) async {
    try {
      pageStatusHandler.progressText("remove_account_pls_wait".tr);
      final result = await _callSynchronized(
          () async => await _controller._removeAccount(account),
          conditionStatus: isOpen);
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  Future<void> switchNetwork(int? networkId) async {
    if (networkId == null || network.value == networkId) return;
    pageStatusHandler.progressText("switching_network".tr);
    await _callSynchronized(
        () async => await _controller._switchNetwork(networkId),
        conditionStatus: isOpen);
    _backToHome();
    pageStatusHandler.success();
    notify();
  }

  Future<void> changeProvider(APIProvider? provider) async {
    if (provider == null) return;
    await _callSynchronized(
        () async => _controller._changeNetworkApiProvider(provider),
        conditionStatus: isOpen,
        delay: null);
    notify();
  }

  Future<MethodResult<List<CryptoPublicKeyData>>> getAccountPubKys(
      {required CryptoAddress account}) async {
    final result = await _callSynchronized(
        () async => _controller._getAccountPubKys(account: account),
        conditionStatus: _isUnlock);
    return result;
  }

  Future<MethodResult<List<CryptoKeyData>>> accsess(
      WalletAccsessType accsessType, String password,
      {CryptoAddress? account, String? accountId}) async {
    final result = await _callSynchronized(
        () async => await _controller._accsess(accsessType, password,
            account: account, accountId: accountId),
        conditionStatus: isOpen,
        onWrongStatus: () => _onWalletLocked(password),
        delay: (accsessType.isUnlock && password.isEmpty)
            ? null
            : APPConst.oneSecoundDuration);
    return result;
  }

  Future<void> updateImportNetwork(WalletNetwork network) async {
    try {
      final result = await _callSynchronized(
          () async => await _controller._updateImportNetwork(network),
          conditionStatus: isOpen);
      if (result.hasError) {
        throw result.exception!;
      }
      return result.result;
    } finally {
      notify();
    }
  }

  Future<MethodResult<String>> generateWalletBackup(String password) async {
    final result = await _callSynchronized(() async {
      return await _controller._generateMrtWalletBackup(password);
    }, conditionStatus: _isUnlock);
    return result;
  }

  Future<MethodResult<void>> switchAccount(CryptoAddress? account) async {
    if (account == null ||
        !_controller.chain.haveAddress ||
        account == _controller.chain.account.address) {
      return MethodResult.succsess(null);
    }
    pageStatusHandler.progressText("switching_account".tr);
    final result = await _callSynchronized(
        () async => _controller._switchAccount(account),
        conditionStatus: isOpen);
    pageStatusHandler.success();
    return result;
  }

  Future<MethodResult<void>> eraseWallet(String password) async {
    try {
      pageStatusHandler.progressText("erase_wallet".tr);
      final result = await _callSynchronized(() async {
        await _eraseWallet(password);
      }, conditionStatus: _isUnlock);
      if (!result.hasError) {
        _backToHome();
      }
      pageStatusHandler.success();
      return result;
    } finally {
      notify();
    }
  }

  void lock() async {
    try {
      await _callSynchronized(() async {
        _controller._logout();
      }, conditionStatus: isOpen, delay: null);
    } finally {
      if (_isLock) {
        _backToHome();
        notify();
      }
    }
  }

  Future<String> _getPassword({
    required Set<AddressDerivationIndex> keys,
    required Set<CryptoAddress<dynamic, dynamic>> addresses,
  }) async {
    bool inRetry = false;

    final pw =
        await _navigatorKey.currentContext?.openSliverBottomSheet<String>(
      "sign_transaction".tr,
      child: WalletSigningPassword(
        addresses: addresses,
        keys: keys,
        onPasswordForm: (password) async {
          try {
            if (inRetry) {
              throw WalletExceptionConst.toManyRequests;
            }
            inRetry = true;
            await Future.delayed(APPConst.oneSecoundDuration);
            if (_isReadOnly) {
              await _controller._login(password);
            } else {
              _validatePassword(password);
            }

            return true;
          } finally {
            inRetry = false;
          }
        },
      ),
    );
    if (pw == null) {
      throw WalletExceptionConst.rejectSigning;
    }
    return pw;
  }

  Future<MethodResult<T>> signTransaction<T>(
      {required SigningRequest<T> request}) async {
    final page = _navigatorKey.currentContext?.path();
    final result = await _callSynchronized(() async {
      late final Set<CryptoAddress> addresses = request.addresses.toSet();
      late final Set<AddressDerivationIndex> keys =
          addresses.map((e) => e.signerKeyIndexes()).expand((e) => e).toSet();
      final password = await _getPassword(addresses: addresses, keys: keys);
      return await _controller._signTransaction(
          request: request,
          password: _controller._toWalletPassword(password),
          signers: keys);
    }, conditionStatus: isOpen);
    if (result.hasResult) {
      final currentPage = _navigatorKey.currentContext?.path();
      if (page != currentPage) {
        throw WalletExceptionConst.pageClosed;
      }
    }

    return result;
  }

  @override
  Future<void> _initWallet() async {
    await _lock.synchronized(() async => await super._initWallet());
    pageStatusHandler.success();
    notify();
    emitWalletListeners();
  }

  Future<void> updateBalance() async {
    if (!isOpen) return;
    await MethodUtils.call(() async {
      await _controller._updateAccountBalance(_controller.chain);
    });
  }

  Future<void> updateAccountBalance(List<CryptoAddress> addresses) async {
    if (!isOpen) return;
    await MethodUtils.call(() async {
      await _controller._updateAccountsBalance(addresses);
    });
  }

  List<EncryptedCustomKey> getCustomKeysForCoin(List<CryptoCoins> coin) {
    if (!isOpen) return const [];
    return _controller._getCustomKeysForCoin(coin);
  }

  Future<List<int>> restoreKeysBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    return await _crypto.decodeBackup(
        backup: backup, password: password, encoding: encoding);
  }

  Future<MRTBackup> restoreMRTBackup(
      {required String backup, required String password}) async {
    MRTBackup mrtBackup;
    final toBytes = BytesUtils.tryFromHexString(backup);
    if (toBytes != null) {
      mrtBackup = MRTBackup.fromCborBytesOrObject(bytes: toBytes);
    } else {
      mrtBackup = MRTKeyBackup(key: backup, type: MrtBackupTypes.keystore);
    }
    final decodeBytes = await restoreKeysBackup(
        backup: mrtBackup.key,
        password: password,
        encoding: mrtBackup.type.encoding);
    return mrtBackup.decrypt(decodeBytes);
  }

  Future<MethodResult<String>> generateMrtBackup(
      {required String data,
      required MrtBackupTypes type,
      required String password}) async {
    if (type == MrtBackupTypes.wallet) {
      throw WalletExceptionConst.dataVerificationFailed;
    }

    final result = await MethodUtils.call(() async {
      return await _controller._generateMrtBackup(
          data: data, password: password, type: type);
    });
    return result;
  }

  Future<HDWallet> createWallet({
    required String mnemonic,
    required String? passphrase,
    required String password,
  }) async {
    if (passphrase?.isEmpty ?? false) {
      throw WalletExceptionConst.invalidMnemonicPassphrase;
    }
    final masterKey =
        await _crypto.generateWalletSeeds(mnemonic, passphrase ?? '');
    final checksum = QuickCrypto.generateRandom(16);
    final pw = _toWalletPassword(password, checksum);
    final encrypt = await _crypto.setup(masterKey: masterKey, key: pw);
    return HDWallet.setup(
        checksum: BytesUtils.toHexString(checksum),
        name: StrUtils.addNumberToMakeUnique(
            _wallets.walletNames, HDWalletsConst.initializeName),
        data: encrypt.$2);
  }

  Future<WalletRestoreV2> restoreWalletBackup({
    required List<int> backupBytes,
    required String? passhphrase,
    required String password,
  }) async {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: backupBytes, tags: CborTagsConst.backupV2);
      final WalletMasterKeys backupkey =
          WalletMasterKeys.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final List<ChainHandler> chains = cbor
          .elementAt<List<dynamic>>(1)
          .map((e) => ChainHandler.fromCborBytesOrObject(obj: e))
          .toList();

      return _restoreWalletBackup(
          backupkey: backupkey,
          chains: chains,
          password: password,
          passhphrase: passhphrase);
    } on WalletException catch (e) {
      if (e == WalletExceptionConst.invalidBackupChecksum) {
        rethrow;
      }
      throw WalletExceptionConst.invalidBackup;
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }

  Future<WalletRestoreV2> restoreWalletBackupV3({
    required MRTBackup backup,
    required String? passhphrase,
    required String password,
  }) async {
    try {
      if (backup.type != MrtBackupTypes.wallet) {
        throw WalletExceptionConst.invalidBackup;
      }
      final WalletMasterKeys backupkey = WalletMasterKeys.fromCborBytesOrObject(
          bytes: BytesUtils.fromHexString(backup.key));
      return _restoreWalletBackup(
          backupkey: backupkey,
          chains: (backup as MRTWalletBackup).chains,
          password: password,
          passhphrase: passhphrase);
    } on WalletException catch (e) {
      if (e == WalletExceptionConst.invalidBackupChecksum) {
        rethrow;
      }
      throw WalletExceptionConst.invalidBackup;
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }

  Future<WalletRestoreV2> _restoreWalletBackup({
    required WalletMasterKeys backupkey,
    required List<ChainHandler> chains,
    required String password,
    required String? passhphrase,
  }) async {
    if (passhphrase?.isEmpty ?? false) {
      throw WalletExceptionConst.invalidMnemonicPassphrase;
    }
    final String mnemonic = backupkey.mnemonic.toStr();
    BlockchainUtils.validateMnemonic(mnemonic);
    WalletMasterKeys masterKey =
        await _crypto.generateWalletSeeds(mnemonic, passhphrase);
    if (backupkey.customKeys.isNotEmpty) {
      masterKey = masterKey.addKey(backupkey.customKeys);
    }

    bool? verifiedChecksum;
    if (!BytesUtils.bytesEqual(masterKey.checksum, backupkey.checksum)) {
      verifiedChecksum = false;
    } else {
      verifiedChecksum = true;
    }
    final v3 = await _validateBackupAccounts(
        chains: chains,
        masterKey: masterKey,
        password: password,
        verifiedChecksum: verifiedChecksum);

    return v3;
  }

  Future<WalletRestoreV2> _validateBackupAccounts(
      {required List<ChainHandler> chains,
      required WalletMasterKeys masterKey,
      required String password,
      required bool? verifiedChecksum}) async {
    final checksum = QuickCrypto.generateRandom(16);
    final pw = _toWalletPassword(password, checksum);
    final encrypt = await _crypto.setup(masterKey: masterKey, key: pw);
    if (verifiedChecksum == false) {
      return WalletRestoreV2._(
          masterKeys: masterKey,
          chains: [],
          invalidAddresses: const [],
          verifiedChecksum: false,
          wallet: HDWallet.setup(
              checksum: BytesUtils.toHexString(checksum),
              name: StrUtils.addNumberToMakeUnique(
                  _wallets.walletNames, HDWalletsConst.initializeName),
              data: encrypt.$2));
    }
    List<ChainHandler> validateChains = [];
    List<CryptoAddress> invalidAddresses = [];
    for (final c in chains) {
      List<CryptoAddress> addresses = [];

      for (final address in c.account.addresses) {
        try {
          final network = c.network;
          if (address.multiSigAccount) {
            final multiSigAccount =
                address.toAccountParams().toAccount(network, const []);
            final isValid = multiSigAccount == address &&
                address.isEqual(multiSigAccount) &&
                address.address.toAddress == multiSigAccount.address.toAddress;
            if (isValid) {
              addresses.add(multiSigAccount);
            } else {
              invalidAddresses.add(address);
            }

            continue;
          }

          final addr = await WalletManager._deriveAddress(
              newAccountParams: address.toAccountParams(),
              crypto: _crypto,
              masterKey: encrypt.$1,
              password: pw);
          final account = addr.$1.toAccount(network, addr.$2);
          final isValid = account == address &&
              address.isEqual(account) &&
              address.address.toAddress == account.address.toAddress;
          if (isValid) {
            addresses.add(account);
          } else {
            invalidAddresses.add(address);
          }
        } catch (e) {
          invalidAddresses.add(address);
        }
      }
      final chain = c.copyWith(
          account: (c.account as Bip32NetworkAccount)
              .copyWith(addresses: addresses));
      validateChains.add(chain);
    }
    return WalletRestoreV2._(
        masterKeys: masterKey,
        chains: chains,
        invalidAddresses: invalidAddresses,
        wallet: HDWallet.setup(
            checksum: BytesUtils.toHexString(checksum),
            name: StrUtils.addNumberToMakeUnique(
                _wallets.walletNames, HDWalletsConst.initializeName),
            data: encrypt.$2),
        verifiedChecksum: verifiedChecksum);
  }

  void _backToHome() {
    _navigatorKey.currentContext?.popToHome();
  }

  int? _lifeTime() {
    if (isOpen) {
      return wallet.locktime.value;
    }
    return null;
  }

  late final LifeCycleTracker _lifeCycleTracker =
      LifeCycleTracker(lock, _lifeTime);

  @override
  void init() {
    _lifeCycleTracker.init();
    _initWallet();
    super.init();
  }

  @override
  void close() {
    super.close();
    _lifeCycleTracker.dispose();
  }
}
