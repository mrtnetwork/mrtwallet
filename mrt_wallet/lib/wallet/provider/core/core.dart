part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

abstract class WalletStateController {
  void addWalletStatusListener(OnWalletEvent listener);
  void removeWalletStatusListener(OnWalletEvent listener);

  void addOnChainChangedListener(DynamicVoid listener);
  void removeOnChainChangedListener(DynamicVoid listener);
  List<String> coinIds();
  void onChange();
  void onChangeStatus(WalletPageStatus status, {String? message});
  bool onWeb3Request(Web3Request request);
}

abstract class _WalletCore extends WalletStateController
    with CryptoWokerImpl, WalletStorageWriter, WalletsStoragesManger {}

abstract class WalletCore extends _WalletCore
    with WalletsManager, WalletsListener {
  @override
  bool get useMemoryStorage => false;
  bool get isJsWallet => false;

  final _lock = SynchronizedLock();
  Chain get chain => _controller._appChains.chain;
  WalletNetwork get network => chain.network;
  WalletNetwork? networkById(int id) =>
      _controller._appChains._networks[id]?.network;
  HDWallet get wallet => _controller._wallet;
  List<HDWallet> get wallets => _wallets._wallets.values.toList()
    ..sort((a, b) => b.created.compareTo(a.created));
  String? get defaultWalletId => _wallets.defaultWallet;
  final _lockWeb3 = SynchronizedLock();

  int? get reminingWalletTime => _wallet?._timeout.remining;

  Future<MethodResult<T>> _walletAction<T>(
    Future<T> Function() t, {
    Duration? delay,
  }) async {
    _wallet?._timeout.init();
    return await MethodUtils.call(() async {
      return t();
    }, delay: delay);
  }

  Future<MethodResult<T>> _callSynchronized<T>(Future<T> Function() t,
      {required bool conditionStatus,
      Duration? delay = APPConst.animationDuraion,
      bool update = true,
      bool refresh = false,
      SynchronizedLock? lock}) async {
    bool statusChanged = false;

    try {
      final result = await (lock ?? _lock).synchronized(() async {
        final status = WalletEventStaus.fromWalletStatus(_wallet?._status);
        final result = await _walletAction(() async {
          if (!conditionStatus) {
            throw WalletExceptionConst.incorrectStatus;
          }
          return await t();
        }, delay: delay);
        final after = WalletEventStaus.fromWalletStatus(_wallet?._status);
        if (status != after) {
          statusChanged = true;
        }
        if (refresh && result.hasError) {
          refresh = false;
        }
        return result;
      });
      return result;
    } finally {
      if (refresh || (statusChanged && isLock)) {
        onChangeStatus(WalletPageStatus.refesh);
      } else {
        onChangeStatus(WalletPageStatus.success);
      }
      if (statusChanged || update) {
        if (statusChanged) {
          _emitWalletListeners();
        }
        onChange();
      }
    }
  }

  @override
  List<String> coinIds() =>
      homePageStatus.isReady ? _controller._appChains.coinIds() : [];

  Future<MethodResult<void>> setup(
      {required HDWallet hdWallet,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    onChangeStatus(WalletPageStatus.progress, message: "launch_the_wallet");
    final result = await _callSynchronized(() async {
      return await _setup(
          hdWallet: hdWallet, password: password, walletInfos: walletInfos);
    }, conditionStatus: true, refresh: true, update: true);
    if (result.hasResult) {
      _emitOnChainChangedListener();
    }
    return result;
  }

  Future<MethodResult<void>> setupBackup(
      {required WalletRestoreV2 backup,
      required String password,
      required WalletUpdateInfosData walletInfos}) async {
    onChangeStatus(WalletPageStatus.progress, message: "launch_the_wallet");
    return await _callSynchronized(() async {
      await _setup(
          hdWallet: backup.wallet,
          password: password,
          walletInfos: walletInfos,
          chains: backup.chains);
    }, conditionStatus: true, refresh: true, update: true);
  }

  Future<MethodResult<Web3EncryptedMessage>> web3Request(
      Web3RequestApplicationInformation request) async {
    final result = await _callSynchronized(() async {
      return await _controller._web3Request(request);
    }, conditionStatus: true, refresh: false, update: false, lock: _lockWeb3);
    return result;
  }

  Future<MethodResult<Web3EncryptedMessage>> getWeb3Authenticated(
      Web3ClientInfo info) async {
    final result = await _callSynchronized(() async {
      return await _controller._getWeb3Authenticated(info);
    },
        conditionStatus: true,
        refresh: false,
        update: false,
        lock: _lockWeb3,
        delay: null);
    return result;
  }

  Future<MethodResult<Web3EncryptedMessage>> getWeb3Permission(
      Web3ClientInfo info) async {
    final result = await _callSynchronized(() async {
      return await _controller._getWeb3Permission(info);
    }, conditionStatus: true, refresh: false, update: false, lock: _lockWeb3);
    return result;
  }

  Future<MethodResult<T>> walletRequest<T, A extends MessageArgs>(
      WalletMessageArgsCompleter<T, A> message) async {
    final result = await _callSynchronized(() async {
      return await _controller._walletRequest(message);
    }, conditionStatus: isUnlock, refresh: false, update: false);
    return result;
  }

  Future<MethodResult<Web3APPAuthentication>> getOrCreateWeb3AppAuthenticated(
      Web3ClientInfo info) async {
    return _walletAction(() => _controller._getOrCreateAppAuthenticated(info));
  }

  Future<MethodResult<Web3EncryptedMessage>> updateWeb3Application(
      Web3APPAuthentication application) async {
    return _callSynchronized(
        () async => _controller._updateWeb3Application(application),
        update: false,
        refresh: false,
        conditionStatus: isUnlock);
  }

  Future<MethodResult<WalletLockTime>> login(String password) async {
    return await _callSynchronized(() async {
      if (isReadOnly || isLock) {
        await _controller._login(password);
      } else {
        await _controller._validatePassword(password);
      }
      return _wallet!._wallet.locktime;
    },
        conditionStatus: homePageStatus.isReady,
        refresh: false,
        update: isReadOnly);
  }

  Future<MethodResult<void>> changePassword(
      String password, String newPassword) async {
    onChangeStatus(WalletPageStatus.progress, message: "changing_password");
    return await _callSynchronized(() async {
      await _controller._changePassword(password, newPassword);
    }, conditionStatus: isUnlock, update: false, refresh: false);
  }

  Future<MethodResult<void>> updateWalletInfos(
      {required WalletUpdateInfosData walletInfos,
      required String password}) async {
    onChangeStatus(WalletPageStatus.progress, message: "updating");
    return await _callSynchronized(() async {
      return await _controller._updateWalletInfos(
          password: password, walletInfos: walletInfos);
    }, conditionStatus: isUnlock, refresh: false, update: false);
  }

  Future<MethodResult<NETWORKCHAINACCOUNT<NETWORKADDRESS>>>
      deriveNewAccount<NETWORKADDRESS>(
          {required NewAccountParams<NETWORKADDRESS> newAccountParams,
          required APPCHAINNETWORK<NETWORKADDRESS> chain}) async {
    onChangeStatus(WalletPageStatus.progress,
        message: "setup_new_account_pls_wait");
    return await _callSynchronized(
        () async => await _controller._deriveNewAccount(
            newAccountParams: newAccountParams, chain: chain),
        conditionStatus: newAccountParams.isMultiSig ? isOpen : isUnlock,
        delay: APPConst.milliseconds100,
        update: true,
        refresh: false);
  }

  Future<MethodResult<void>> importAccount(
      ImportedKeyStorage newAccountParams, String password) async {
    final result = await _callSynchronized(
        () async => await _controller._importNewKey(newAccountParams, password),
        conditionStatus: isUnlock,
        refresh: false,
        update: false);
    return result;
  }

  Future<void> switchWallet(HDWallet? wallet) async {
    if (wallet == null) return;
    onChangeStatus(WalletPageStatus.progress, message: "switching_wallet");
    final result = await _callSynchronized(() async {
      return await _switchWallet(wallet);
    }, conditionStatus: homePageStatus.isReady, refresh: true, update: true);
    if (result.hasResult && result.result) {
      _emitOnChainChangedListener();
    }
  }

  Future<MethodResult<void>> addNewContact<NETWORKADDRESS>(
      {required ContactCore<NETWORKADDRESS> newContact,
      required APPCHAINNETWORK<NETWORKADDRESS> account}) async {
    final result = await _callSynchronized(
      () async => await _controller._addNewContact(
          newContact: newContact, account: account),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
    return result;
  }

  Future<MethodResult<void>> addNewToken<
          NETWORKADDRESS,
          TOKEN extends TokenCore,
          CHAINACCOUNT extends NETWORKCHAINACCOUNT<NETWORKADDRESS>>(
      {required TOKEN token,
      required CHAINACCOUNT address,
      required APPCHAINACCOUNT<CHAINACCOUNT> account}) async {
    return await _callSynchronized(
      () async => await _controller._addNewToken(
          account: account, token: token, address: address),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>> removeToken<
          NETWORKADDRESS,
          TOKEN extends TokenCore,
          CHAINACCOUNT extends NETWORKCHAINACCOUNT<NETWORKADDRESS>>(
      {required TOKEN token,
      required CHAINACCOUNT address,
      required APPCHAINACCOUNT<CHAINACCOUNT> account}) async {
    return await _callSynchronized(
      () async => await _controller._removeToken(
          token: token, address: address, account: account),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>> updateToken<
          NETWORKADDRESS,
          TOKEN extends TokenCore,
          CHAINACCOUNT extends NETWORKCHAINACCOUNT<NETWORKADDRESS>>(
      {required Token updatedToken,
      required TOKEN token,
      required CHAINACCOUNT address,
      required APPCHAINACCOUNT<CHAINACCOUNT> account}) async {
    return await _callSynchronized(
      () async => await _controller._updateToken(
          token: token,
          address: address,
          updatedToken: updatedToken,
          account: account),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>>
      addNewNFT<NFT extends NFTCore, APPCHAIN extends APPCHAINNFT<NFT>>({
    required NFT nft,
    required APPCHAIN account,
    required NFTCHAINACCOUNT<NFT> address,
  }) async {
    return await _callSynchronized(
      () async => await _controller._addNewNFT(
          nft: nft, address: address, account: account),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>>
      removeNFT<NFT extends NFTCore, APPCHAIN extends APPCHAINNFT<NFT>>({
    required NFT nft,
    required APPCHAIN account,
    required NFTCHAINACCOUNT<NFT> address,
  }) async {
    return await _callSynchronized(
      () async => await _controller._removeNFT(
          nft: nft, address: address, account: account),
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>> setupAccountName<CHAINTOKEN extends ChainAccount>(
      {String? name,
      required APPCHAINACCOUNT<CHAINTOKEN> account,
      required CHAINTOKEN address}) async {
    if (name == null || !APPConst.accountNameRegExp.hasMatch(name)) {
      return MethodResult.success(null);
    }
    return await _callSynchronized(
      () async {
        await _controller._setAccountName(
            name: name.trim().isEmpty ? null : name,
            address: address,
            account: account);
      },
      conditionStatus: isOpen,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<List<EncryptedCustomKey>>> getImportedAccounts(
      String password) {
    final result = _callSynchronized(() async {
      return _controller._getImportedAccounts(password);
    }, conditionStatus: isUnlock, refresh: false, update: false);
    return result;
  }

  List<T> networks<T extends WalletNetwork>() {
    if (isOpen) {
      return _controller._appChains.networks().whereType<T>().toList();
    }
    return [];
  }

  List<T> getChains<T extends APPCHAIN>() {
    if (isOpen) {
      return _controller._appChains.chains().whereType<T>().toList();
    }
    return [];
  }

  Future<MethodResult<void>> removeImportedKey(
      EncryptedCustomKey key, String password) {
    onChangeStatus(WalletPageStatus.progress, message: "removing_key_pls_wait");
    return _callSynchronized(
      () async {
        return await _controller._removeKey(key, password);
      },
      conditionStatus: isUnlock,
      refresh: false,
      update: true,
    );
  }

  Future<MethodResult<void>> removeAccount<CHAINTOKEN extends ChainAccount>(
      {required APPCHAINACCOUNT<CHAINTOKEN> account,
      required CHAINTOKEN address}) async {
    onChangeStatus(WalletPageStatus.progress,
        message: "remove_account_pls_wait");
    final result = await _callSynchronized(
        () async => await _controller._removeAccount(
            account: account, address: address),
        conditionStatus: isOpen,
        refresh: false,
        update: true);
    if (result.hasResult && result.result) {
      _emitOnChainChangedListener();
    }
    return result;
  }

  Future<void> switchNetwork(int? networkId) async {
    if (networkId == null || network.value == networkId) return;
    onChangeStatus(WalletPageStatus.progress, message: "switching_network");
    await _callSynchronized(
      () async => await _controller._switchNetwork(networkId),
      conditionStatus: isOpen,
      refresh: true,
      update: true,
    );
  }

  Future<void> changeCurrentNetworkProvider<PROVIDER extends APIProvider>(
      {required PROVIDER provider,
      required APPCHAINNETWORKPROVIDER account}) async {
    await _callSynchronized(
        () async => _controller._changeNetworkApiProvider(
            provider: provider, account: account),
        conditionStatus: isOpen,
        delay: null,
        refresh: false,
        update: true);
  }

  Future<MethodResult<List<CryptoPublicKeyData>>> getAccountPubKys(
      {required ChainAccount account}) async {
    final result = await _callSynchronized(
      () async => _controller._getAccountPubKys(account: account),
      conditionStatus: isUnlock,
      refresh: false,
      update: false,
    );
    return result;
  }

  Future<MethodResult<List<CryptoKeyData>>> accsess(
      WalletAccsessType accsessType, String password,
      {ChainAccount? account, String? accountId}) async {
    final result = await _callSynchronized(
      () async {
        if (accsessType.isUnlock && isUnlock) {
          return [FakeKeyData()];
        } else if (isReadOnly || isLock) {
          await _controller._login(password);
        } else {
          await _controller._validatePassword(password);
        }
        return await _controller._accsess(accsessType,
            account: account, accountId: accountId);
      },
      conditionStatus: _homePageStatus.isReady,
      delay: (accsessType.isUnlock && password.isEmpty)
          ? null
          : APPConst.oneSecoundDuration,
      refresh: false,
      update: true,
    );
    return result;
  }

  Future<void> updateImportNetwork(WalletNetwork network) async {
    final result = await _callSynchronized(
        () async => await _controller._updateImportNetwork(network),
        conditionStatus: isOpen,
        refresh: false,
        update: true);
    if (result.hasResult) {
      _emitOnChainChangedListener();
    }
    return result.result;
  }

  Future<MethodResult<void>> removeChain(Chain chain) async {
    onChangeStatus(WalletPageStatus.progress,
        message: "remove_account_pls_wait");
    final result = await _callSynchronized(
      () async => await _controller._removeChain(chain),
      conditionStatus: isOpen,
      refresh: this.chain == chain,
      update: true,
    );
    if (result.hasResult) {
      _emitOnChainChangedListener();
    }
    return result;
  }

  Future<MethodResult<String>> generateWalletBackup(String password) async {
    final result = await _callSynchronized(
      () async {
        return await _controller._generateMrtWalletBackup(password);
      },
      conditionStatus: isUnlock,
      refresh: false,
      update: false,
    );
    return result;
  }

  Future<MethodResult<void>> switchAccount<CHAINTOKEN extends ChainAccount>(
      {required APPCHAINACCOUNT<CHAINTOKEN> account,
      required CHAINTOKEN address,
      bool? closePages}) async {
    onChangeStatus(WalletPageStatus.progress, message: "switching_account");
    return await _callSynchronized(
      () async =>
          _controller._switchAccount(account: account, address: address),
      conditionStatus: isOpen,
      refresh: closePages ?? true,
      update: true,
    );
  }

  Future<MethodResult<void>> eraseWallet(String password) async {
    onChangeStatus(WalletPageStatus.progress, message: "erase_wallet");
    final result = await _callSynchronized(() async {
      await _eraseWallet(password);
    }, conditionStatus: isUnlock, refresh: true, update: true);
    if (result.hasResult) {
      _emitOnChainChangedListener();
    }
    return result;
  }

  Future<void> lock() async {
    await _callSynchronized(
      () async {
        _controller._logout();
      },
      conditionStatus: isOpen,
      delay: null,
      refresh: _wallet?._wallet.requiredPassword ?? false,
      update: true,
    );
  }

  Future<MethodResult<T>> signRequest<T>(
      {required WalletSigningRequest<T> request, String? password}) async {
    final result = await _callSynchronized(
      () async {
        late final Set<ChainAccount> addresses = request.addresses.toSet();
        late final Set<AddressDerivationIndex> keys =
            addresses.map((e) => e.signerKeyIndexes()).expand((e) => e).toSet();
        return await _controller._signTransaction(
            request: request, password: password, signers: keys);
      },
      conditionStatus: isUnlock,
      refresh: false,
      update: false,
    );

    return result;
  }

  Future<void> initWallet(
      {bool useIsolate = true, String? initialPassword}) async {
    await _lock.synchronized(
        () async => await super._initWallet(useIsolate: useIsolate));
    if (initialPassword != null) {
      await _walletAction(() => _controller._login(initialPassword));
    }
    onChangeStatus(WalletPageStatus.success);
    if (_homePageStatus.isReady) {
      _emitWalletListeners();
    }
    onChange();
  }

  Future<MethodResult<void>> updateCurrentAccountBalance() async {
    return await _walletAction(() async {
      final chain = _wallet?.chain;
      if (chain != null && chain.haveAddress) {
        return await _controller._updateAaddressBalance(
            account: chain, address: chain.address);
      }
    });
  }

  Future<void> updateAccountBalance(Chain account) async {
    if (!isOpen) return;
    await _walletAction(() => _controller._updateAccountBalance(account));
  }

  Future<List<EncryptedCustomKey>> getCustomKeysForCoin(
      List<CryptoCoins> coin) async {
    if (!isOpen) return const [];
    final result = await _callSynchronized(() async {
      return _controller._getCustomKeysForCoin(coin);
    },
        conditionStatus: isOpen,
        refresh: false,
        update: true,
        delay: Duration.zero);
    return result.result;
  }

  Future<List<int>> restoreKeysBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    return await crypto.cryptoRequest(
      CryptoRequestDecodeBackup(
          password: password, backup: backup, encoding: encoding),
    );
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

  Future<HDWallet> createWallet(
      {required String mnemonic,
      required String? passphrase,
      required String password}) async {
    if (passphrase?.isEmpty ?? false) {
      throw WalletExceptionConst.invalidMnemonicPassphrase;
    }
    final checksum = await crypto.generateRandomBytes(
        length: CreateHDWalletConst.checksumLength,
        existsKeys:
            _wallets._wallets.values.map((e) => e.checkSumBytes).toList());
    final encrypt = await crypto.cryptoRequest(CryptoRequestCreateHDWallet(
        mnemonic: mnemonic,
        passphrase: passphrase,
        password: password,
        checksum: checksum));
    return HDWallet.setup(
        checksum: BytesUtils.toHexString(checksum),
        name: StrUtils.addNumberToMakeUnique(
            _wallets.walletNames, HDWalletsConst.initializeName),
        data: encrypt.storageData);
  }

  Future<WalletRestoreV2> restoreWalletBackupV3(
      {required MRTBackup backup,
      required String? passhphrase,
      required String password}) async {
    try {
      if (backup.type != MrtBackupTypes.wallet) {
        throw WalletExceptionConst.invalidBackup;
      }
      if (passhphrase?.isEmpty ?? false) {
        throw WalletExceptionConst.invalidMnemonicPassphrase;
      }
      final WalletMasterKeys backupkey =
          WalletMasterKeys.deserializeBackup(hex: backup.key);
      final String mnemonic = backupkey.mnemonic.toStr();
      WalletMasterKeys masterKey = await crypto.cryptoRequest(
          CryptoRequestCreateMasterKey(
              mnemonic: mnemonic, passphrase: passhphrase));
      if (backupkey.customKeys.isNotEmpty) {
        for (final i in backupkey.customKeys) {
          masterKey = masterKey.importCustomKey(i, validateChecksum: false);
        }
      }
      bool? verifiedChecksum;
      if (!BytesUtils.bytesEqual(masterKey.checksum, backupkey.checksum)) {
        verifiedChecksum = false;
      } else {
        verifiedChecksum = true;
      }
      return await _validateBackupAccounts(
          chains: (backup as MRTWalletBackup).chains,
          masterKey: masterKey,
          password: password,
          verifiedChecksum: verifiedChecksum);
    } on WalletException catch (e) {
      if (e == WalletExceptionConst.invalidBackupChecksum) {
        rethrow;
      }
      throw WalletExceptionConst.invalidBackup;
    } catch (e) {
      throw WalletExceptionConst.invalidBackup;
    }
  }

  Future<WalletRestoreV2> _validateBackupAccounts(
      {required List<Chain> chains,
      required WalletMasterKeys masterKey,
      required String password,
      required bool? verifiedChecksum}) async {
    final checksum = await crypto.generateRandomHex(
      length: CreateHDWalletConst.checksumLength,
      existsKeys: _wallets._wallets.values.map((e) => e.checkSumBytes).toList(),
    );
    final key = await _toWalletPassword(password, checksum);
    final setupKey = await crypto.cryptoRequest(
        CryptoRequestSetupMasterKey(masterKey: masterKey, key: key));
    if (verifiedChecksum == false) {
      return WalletRestoreV2._(
          masterKeys: masterKey,
          chains: [],
          invalidAddresses: const [],
          verifiedChecksum: false,
          wallet: HDWallet.setup(
              checksum: checksum,
              name: StrUtils.addNumberToMakeUnique(
                  _wallets.walletNames, HDWalletsConst.initializeName),
              data: setupKey.storageData));
    }
    List<Chain> validateChains = [];
    List<ChainAccount> invalidAddresses = [];
    try {
      for (final c in chains) {
        List<ChainAccount> addresses = [];

        for (final address in c.addresses) {
          try {
            final network = c.network;
            if (address.multiSigAccount) {
              final multiSigAccount =
                  address.toAccountParams().toAccount(network, const []);
              final isValid = multiSigAccount == address &&
                  address.isEqual(multiSigAccount) &&
                  address.address.toAddress ==
                      multiSigAccount.address.toAddress;
              if (isValid) {
                addresses.add(multiSigAccount);
              } else {
                invalidAddresses.add(address);
              }

              continue;
            }
            final addr = await crypto.walletArgs(
                message: WalletRequestDeriveAddress(
                    addressParams: address.toAccountParams()),
                encryptedMasterKey: setupKey.masterKey.masterKey,
                key: key);
            final account = addr.toAccount(network);
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
            addresses: c.addresses.where((e) => addresses.contains(e)).toList(),
            id: checksum);
        validateChains.add(chain);
      }
      // ignore: empty_catches
    } catch (e) {}
    return WalletRestoreV2._(
        masterKeys: masterKey,
        chains: validateChains,
        invalidAddresses: invalidAddresses,
        wallet: HDWallet.setup(
            checksum: checksum,
            name: StrUtils.addNumberToMakeUnique(
                _wallets.walletNames, HDWalletsConst.initializeName),
            data: setupKey.storageData),
        verifiedChecksum: verifiedChecksum);
  }
}
