// ignore_for_file: library_private_types_in_public_api

part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletManager2 on _WalletController {
  final _crypto = IsolateCryptoWoker();
  late HDWalletStatus _status =
      _wallet.requiredPassword ? HDWalletStatus.lock : HDWalletStatus.readOnly;

  bool get isLock => _status == HDWalletStatus.lock;
  bool get isReadOnly => _status == HDWalletStatus.readOnly;
  bool get isUnlock => _status == HDWalletStatus.unlock;
  @override
  bool get isOpen => _status.isOpen;

  List<int>? _password;
  EncryptedMasterKey? _massterKey;

  void _setDefaultPageStatus() {
    _massterKey = null;
    _password = null;
    if (_wallet.requiredPassword) {
      _status = HDWalletStatus.lock;
    } else {
      _status = HDWalletStatus.readOnly;
    }
  }

  void _logout() {
    if (!_wallet.requiredPassword) return;
    _massterKey = null;
    _password = null;
    _status = HDWalletStatus.lock;
  }

  Future<void> _login(String password) async {
    final pw = _toWalletPassword(password);
    final storageKey = await _crypto.generateMasterKey(_wallet._data, pw);
    _massterKey = storageKey.$1;
    _password = pw;
    _status = HDWalletStatus.unlock;
  }

  Future<CryptoAddress> _deriveNewAccount(
      NewAccountParams newAccountParams) async {
    if (newAccountParams.isMultiSig) {
      return await _addNewAccountToNetwork(newAccountParams, const []);
    }
    if (newAccountParams.deriveIndex.isMultiSig) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (!network.coins.contains(newAccountParams.coin)) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final updateParams = await _deriveAddress(
        crypto: _crypto,
        masterKey: _massterKey!,
        newAccountParams: newAccountParams,
        password: _password!);
    final CryptoAddress newAccount =
        await _addNewAccountToNetwork(updateParams.$1, updateParams.$2);
    return newAccount;
  }

  Future<void> _importNewKey(ImportedKeyStorage newKey, String password) async {
    final pw = _validatePassword(password);
    final encrypt = await _crypto.importCustomKey(
        newKey: newKey, key: pw, encryptedWallet: _massterKey!.masterKey);
    _massterKey = encrypt.$1;
    await _updateWalletData(encrypt.$2);
  }

  Future<void> _removeKey(EncryptedCustomKey removeKey, String password) async {
    final pw = _validatePassword(password);
    if (!_massterKey!.customKeys.contains(removeKey)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    await _cleanUpdateRemovedKeyAccounts(removeKey.id);
    final encrypt = await _crypto.removeMasterKey(
        removeKey: removeKey, key: pw, encryptedWallet: _massterKey!.masterKey);
    _massterKey = encrypt.$1;
    await _updateWalletData(encrypt.$2);
  }

  List<int> _validatePassword(String password) {
    if (!isUnlock) {
      throw WalletExceptionConst.walletIsLocked;
    }

    final toPw = _toWalletPassword(password);
    if (!BytesUtils.bytesEqual(toPw, _password)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    return toPw;
  }

  Future<void> _changePassword(String password, String newPassword) async {
    if (!StrUtils.isStrongPassword(newPassword)) {
      throw WalletExceptionConst.incorrectPassword;
    }
    if (password == newPassword) {
      throw WalletExceptionConst.passwordUsedBefore;
    }
    final pw = _validatePassword(password);
    final nPassword = _toWalletPassword(newPassword);

    final encrypt = await _crypto.changePassword(
        newPassword: nPassword,
        key: pw,
        encryptedWallet: _massterKey!.masterKey);
    await _updateWalletData(encrypt.$2);
    _setDefaultPageStatus();
  }

  Future<String> _generateMrtBackup(
      {required String data,
      required MrtBackupTypes type,
      required String password}) async {
    final encryptKey = await _crypto.createBackup2(
        backup: type.toEncryptionBytes(data),
        encoding: type.encoding,
        password: password);
    if (type == MrtBackupTypes.keystore) {
      return encryptKey;
    }
    final mrtBackup = MRTKeyBackup(key: encryptKey, type: type);
    return mrtBackup.toCbor().toCborHex();
  }

  Future<String> _generateMrtWalletBackup(String password) async {
    final pw = _validatePassword(password);
    final storageKey =
        await _crypto.masterKeyfromMemoryStorage(pw, _massterKey!.masterKey);
    final encrypt = await _crypto.createBackup2(
        backup: storageKey.toCbor().encode(),
        encoding: SecretWalletEncoding.cbor,
        password: password);
    final mrtBackup =
        MRTWalletBackup(key: encrypt, chains: _appChains.chains());
    return mrtBackup.toCbor().toCborHex();
  }

  Future<List<CryptoKeyData>> _accsess(
      WalletAccsessType accsessType, String password,
      {CryptoAddress? account, String? accountId}) async {
    if (accsessType.isAccsessKey && account == null && accountId == null) {
      throw WalletException.invalidArgruments(["CryptoAddress", "null"]);
    }
    if (accsessType.isUnlock && isUnlock) {
      return [FakeKeyData()];
    }

    if (isReadOnly) {
      await _login(password);
    }
    if (accsessType.isUnlock) {
      return [FakeKeyData()];
    }
    final toPassword = _validatePassword(password);
    if (accsessType.isAccsessKey) {
      if (account != null) {
        final indexes = account.accessKeysIndexes();
        final accountKeys = await _crypto.readPrivateKeys(
            keysRequest: AccessCryptoPrivateKeysRequest(indexes
                .map((e) => AccessCryptoPrivateKeyRequest(index: e))
                .toList()),
            key: toPassword,
            encryptedWallet: _massterKey!.masterKey);
        return accountKeys;
      } else {
        final importedKey = await _crypto.getImportedKey(
            keyId: accountId!,
            key: _validatePassword(password),
            encryptedWallet: _massterKey!.masterKey);
        return [importedKey];
      }
    } else if (accsessType.isAccessMnemonic) {
      final mnemonic = await _crypto.readMnemonic(
          key: toPassword, encryptedWallet: _massterKey!.masterKey);
      return [mnemonic];
    } else {
      return [FakeKeyData()];
    }
  }

  Future<List<CryptoPublicKeyData>> _getAccountPubKys(
      {required CryptoAddress account}) async {
    final indexes = account.accessKeysIndexes();
    return await _crypto.readPublicKeys(
        keysRequest: AccessCryptoPrivateKeysRequest(indexes
            .map((e) => AccessCryptoPrivateKeyRequest(index: e))
            .toList()),
        key: _password!,
        encryptedWallet: _massterKey!.masterKey);
  }

  Future<T> _signTransaction<T>(
      {required List<int> password,
      required Set<Bip32AddressIndex> signers,
      required SigningRequest<T> request}) async {
    final sign = await request.sign((request) async {
      if (!signers.contains(request.index)) {
        throw WalletExceptionConst.notAuthorizedSigningAccount;
      }
      return await _crypto.sign(
          encryptedWallet: _massterKey!.masterKey,
          key: password,
          signingRequest: request);
    });
    return sign;
  }

  static Future<(NewAccountParams, List<int>)> _deriveAddress(
      {required NewAccountParams newAccountParams,
      required IsolateCryptoWoker crypto,
      required EncryptedMasterKey masterKey,
      required List<int> password}) async {
    if (newAccountParams is CardanoNewAddressParams) {
      final cardanoAccount = await _deriveCardanoNewAddress(
          params: newAccountParams,
          crypto: crypto,
          masterKey: masterKey,
          password: password);
      return (cardanoAccount, cardanoAccount.addressDetails!.publicKey);
    }
    final key = await crypto.readPublicKey(
        keyRequest: AccessCryptoPrivateKeyRequest(
            index: newAccountParams.deriveIndex as Bip32AddressIndex),
        key: password,
        encryptedWallet: masterKey.masterKey);
    return (newAccountParams, key.keyBytes());
  }

  static Future<CardanoNewAddressParams> _deriveCardanoNewAddress(
      {required CardanoNewAddressParams params,
      required IsolateCryptoWoker crypto,
      required EncryptedMasterKey masterKey,
      required List<int> password}) async {
    final bool byronLegacy = params.coin.proposal == CustomProposal.cip0019;
    final bip = await crypto.readPublicKey(
        keyRequest: AccessCryptoPrivateKeyRequest(
            index: params.deriveIndex as Bip32AddressIndex,
            maxLevel:
                (byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex)
                    .value),
        key: password,
        encryptedWallet: masterKey.masterKey);
    final CardanoAddrDetails addrDetails;
    switch (params.addressType) {
      case ADAAddressType.base:
        final stake = await crypto.readPublicKey(
            keyRequest: AccessCryptoPrivateKeyRequest(
              index: params.rewardKeyIndex!,
            ),
            key: password,
            encryptedWallet: masterKey.masterKey);

        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.keyBytes(),
            stakePubkey: stake.keyBytes(),
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.enterprise:
      case ADAAddressType.reward:
        addrDetails = CardanoAddrDetails.shelley(
            publicKey: bip.keyBytes(),
            addressType: params.addressType,
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      case ADAAddressType.byron:
        if (byronLegacy) {
          final adaPubKey = (bip as AdaLegacyPublicKeyData);
          addrDetails = CardanoAddrDetails.byron(
              publicKey: bip.keyBytes(),
              chainCode: bip.chainCodeBytes(),
              seedGeneration: params.deriveIndex.seedGeneration,
              hdPathKey: params.customHdPathKey ?? adaPubKey.hdPathKeyBytes(),
              hdPath: params.customHdPath ?? params.deriveIndex.hdPath);
          break;
        }

        addrDetails = CardanoAddrDetails.byron(
            publicKey: bip.keyBytes(),
            chainCode: bip.chainCodeBytes(),
            seedGeneration: params.deriveIndex.seedGeneration);
        break;
      default:
        throw UnimplementedError();
    }
    return params.copyWith(addressDetails: addrDetails);
  }

  List<int> _toWalletPassword(String password) {
    final List<int> key = SHA3.hash(List.from([
      ...StringUtils.encode(password),
      ...BytesUtils.fromHexString(_wallet._checksum)
    ]));
    return List<int>.unmodifiable(
        key.sublist(0, WalletProviderConst.encryptionKeyLength));
  }

  List<EncryptedCustomKey> _getCustomKeysForCoin(List<CryptoCoins> coin) {
    final curves = coin.map((e) => e.conf.type).toList();
    return List<EncryptedCustomKey>.unmodifiable(
      _massterKey!.customKeys.where((element) {
        return coin.contains(element.coin) ||
            (element.keyType.isPrivateKey &&
                curves.contains(element.coin.conf.type));
      }),
    );
  }

  List<EncryptedCustomKey> _getImportedAccounts(String password) {
    _validatePassword(password);
    return List<EncryptedCustomKey>.from(_massterKey!.customKeys);
  }

  Future<void> _updateWalletInfos(
      {required WalletUpdateInfosData walletInfos,
      required String password}) async {
    _validatePassword(password);
    final requiredPassword = _wallet.requiredPassword;
    final updatedWallet = _wallet._updateSettings(
        newLockTime: walletInfos.lockTime,
        reqPassword: walletInfos.requirmentPassword,
        newName: walletInfos.name);
    await _updateWallet(updatedWallet, walletInfos.asDefaultWallet);
    if (!requiredPassword && _wallet.requiredPassword) {
      _setDefaultPageStatus();
    }
  }

  Future<void> _dispose() async {
    _disposeBalanceUpdater();
  }
}
