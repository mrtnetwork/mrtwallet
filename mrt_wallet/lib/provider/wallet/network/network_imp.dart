part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletNetworkImpl on WalletCryptoImpl, WalletStorageImpl, MasterKeyImpl {
  AppChains _appChains = AppChains.setup();
  AppChain get chain => _appChains.chain;
  AppNetworkImpl get network => chain.network;
  bool get walletIsUnlock;

  List<AppNetworkImpl> networks() {
    return _appChains.networks.values.map((e) => e.network).toList();
  }

  List<AppChain> getChains() {
    return _appChains.networks.values.toList();
  }

  Future<void> _updateImportNetwork(AppNetworkImpl network) async {
    final newChain = _appChains.updateImportNetwork(network);
    await _saveAccount(newChain);
  }

  Future<void> _switchAccount(CryptoAccountAddress account) async {
    final acc = chain;
    acc.account.switchAccount(account);
    await _saveAccount(acc);
  }

  Future<void> _removeAccount(CryptoAccountAddress account) async {
    final acc = chain;
    acc.account.removeAccount(account);
    await _saveAccount(acc);
  }

  Future<CryptoAccountAddress> _addNewAccountToNetwork(
    NewAccountParams accountParams,
    List<int> publicKey,
  ) async {
    final acc = chain;
    final address = acc.account.addNewAddress(publicKey, accountParams);
    await _saveAccount(acc);
    _updateAccountBalance(acc, address: address);
    await MethodCaller.wait();
    return address;
  }

  Future<void> _addNewContact(ContactCore newContact) async {
    final acc = chain;
    acc.account.addContact(newContact);
    await _saveAccount(acc);
  }

  Future<void> _addNewToken(
      TokenCore token, CryptoAccountAddress address) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.addToken(token);
    await _saveAccount(acc);
  }

  Future<void> _removeToken(
      TokenCore token, CryptoAccountAddress address) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.removeToken(token);
    await _saveAccount(acc);
  }

  Future<void> _updateToken({
    required TokenCore token,
    required Token updatedToken,
    required CryptoAccountAddress address,
  }) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.updateToken(token, updatedToken);
    await _saveAccount(acc);
  }

  Future<void> _addNewNFT(NFTCore nft, CryptoAccountAddress address) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.addNFT(nft);
    await _saveAccount(acc);
  }

  Future<void> _removeNFT(NFTCore nft, CryptoAccountAddress address) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.removeNFT(nft);
    await _saveAccount(acc);
  }

  Future<void> _setAccountName(
      String? name, CryptoAccountAddress address) async {
    final acc = chain;
    final currentAccount = acc.account;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.setAccountName(name);
    await _saveAccount(acc);
  }

  Future<void> _updateAccountBalance(AppChain? account,
      {CryptoAccountAddress? address}) async {
    if (account == null || !account.haveAddress) return;
    if (address != null && !account.account.addresses.contains(address)) return;
    await account
        .provider()
        ?.updateBalance(address ?? account.account.address)
        .catchError((e) {});
    account.account.refreshTotalBalance();
    await _saveAccount(account);
  }

  Future<void> _updateAccountsBalance(AppChain? account) async {
    if (account == null || !account.haveAddress) return;
    final provider = account.provider();
    for (final i in account.account.addresses) {
      await provider?.updateBalance(i).catchError((e) {
        return null;
      });
    }
    account.account.refreshTotalBalance();
    await _saveAccount(account);
  }

  Future<void> _setupNetwork() async {
    _appChains = await _readNetwork();
  }

  Future<void> _switchNetwork(int changeNetwork) async {
    if (network.value == changeNetwork ||
        !_appChains.networks.containsKey(changeNetwork)) return;
    _appChains.setNetwork(changeNetwork);
    await _saveNetworkId(_appChains.network.value);
  }

  Future<void> _changeNetworkApiProvider(ApiProviderService provider) async {
    final currentNetwork = chain;
    currentNetwork.setProvider(provider);
    await _saveNetwork(currentNetwork);
  }

  List<CryptoAccountAddress> _notAccessAddresses(
      NetworkAccountCore account, List<EncryptedCustomKey> existKeys) {
    final signers =
        List<String>.unmodifiable(existKeys.map((e) => e.id).toList());
    List<CryptoAccountAddress> removeList = [];
    for (final address in account.addresses) {
      if (address.multiSigAccount) {
        final multiSigAccount = address as MultiSigCryptoAccountAddress;
        for (final i in multiSigAccount.keyDetails) {
          final key = i.$2 as Bip32AddressIndex;
          if (!key.isImportedKey) continue;
          if (signers.contains(key.importedKeyId)) continue;
          removeList.add(address);
          break;
        }
      } else {
        final key = address.keyIndexes as Bip32AddressIndex;
        if (!key.isImportedKey) continue;
        if (signers.contains(key.importedKeyId)) continue;
        removeList.add(address);
      }
    }
    return removeList;
  }

  Future<void> _cleanUpAccount(
      {required NetworkAccountCore account,
      required List<EncryptedCustomKey> existKeys}) async {
    final removedAddresses = _notAccessAddresses(account, existKeys);
    if (removedAddresses.isEmpty) return;
    for (final address in removedAddresses) {
      MethodCaller.nullOnException(() => account.removeAccount(address));
    }
    await _saveAccount(_appChains.fromAccount(account));
  }

  final Cancelable _balanceUpdaterCancelable = Cancelable();
  StreamSubscription<void>? _balanceUpdaterStream;
  void _accountBalanceStream() {
    _disposeBalanceUpdater();
    _balanceUpdaterStream = MethodCaller.prediocCaller(
            () => MethodCaller.call(() async {
                  for (final acc in _appChains.networks.values) {
                    for (final i in acc.account.addresses) {
                      if (!walletIsUnlock) return;
                      try {
                        await acc.provider()?.updateBalance(i);
                      } catch (e) {
                        continue;
                      }
                    }
                    await _saveAccount(acc);
                  }
                }),
            canclable: _balanceUpdaterCancelable,
            waitOnSuccess: const Duration(minutes: 10))
        .listen(
      (event) {},
    );
  }

  void _disposeBalanceUpdater() {
    _balanceUpdaterStream?.cancel();
    _balanceUpdaterStream = null;
    _balanceUpdaterCancelable.cancel();
  }
}
