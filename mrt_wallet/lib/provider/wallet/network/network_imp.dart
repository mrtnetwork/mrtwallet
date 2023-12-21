part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletNetworkImpl
    on
        NetworkApiProviderImpl,
        WalletCryptoImpl,
        WalletStorageImpl,
        MasterKeyImpl {
  AppNetworkImpl _network = AppBitcoinNetwork.bitcoinTestnet;
  AppNetworkImpl get network => _network;
  NetworkAccountCore? _account;
  bool get haveAddress => _account?.haveAddress ?? false;
  NetworkAccountCore get networkAccount => _account!;

  void _changeNetwork(AppNetworkImpl newNetwork,
      {ApiProviderService? provider}) {
    _setProvider(newNetwork, provider: provider);
    _network = newNetwork;
  }

  Future<void> _switchAccount(CryptoAccountAddress account) async {
    final acc = networkAccount;
    acc.switchAccount(account);
    await _saveAccount(acc);
  }

  Future<void> _removeAccount(CryptoAccountAddress account) async {
    final acc = networkAccount;
    acc.removeAccount(account);
    await _saveAccount(acc);
  }

  Future<void> _readAccounts() async {
    _account = null;
    final acc = await _readNetworkAccout(_network);
    _account = await _clenCustomKeysAccount(acc, _massterKey!.customKeys);
  }

  Future<void> _addNewAccountToNetwork(
    NewAccountParams accountParams,
    List<int> publicKey,
  ) async {
    final currentAccount = _account!;
    currentAccount.addNewAddress(publicKey, accountParams);
    await _saveAccount(currentAccount);
  }

  Future<void> _addNewContact(ContactCore newContact) async {
    final currentAccount = _account!;
    currentAccount.addContact(newContact);
    await _saveAccount(currentAccount);
  }

  Future<void> _addNewToken(
      TokenCore token, CryptoAccountAddress address) async {
    final currentAccount = _account!;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.addToken(token);
    await _saveAccount(currentAccount);
  }

  Future<void> _removeToken(
      TokenCore token, CryptoAccountAddress address) async {
    final currentAccount = _account!;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.removeToken(token);
    await _saveAccount(currentAccount);
  }

  Future<void> _addNewNFT(NFTCore nft, CryptoAccountAddress address) async {
    final currentAccount = _account!;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.addNFT(nft);
    await _saveAccount(currentAccount);
  }

  Future<void> _removeNFT(NFTCore nft, CryptoAccountAddress address) async {
    final currentAccount = _account!;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.removeNFT(nft);
    await _saveAccount(currentAccount);
  }

  Future<void> _setAccountName(
      String? name, CryptoAccountAddress address) async {
    final currentAccount = _account!;
    if (!currentAccount.addresses.contains(address)) {
      throw WalletExceptionConst.accountDoesNotFound;
    }
    address.setAccountName(name);
    await _saveAccount(currentAccount);
  }

  Future<void> _setupNetwork() async {
    final networkId = await _readNetwork();
    _changeNetwork(networkId?.$1 ?? _network, provider: networkId?.$2);
  }

  Future<void> _switchNetwork(AppNetworkImpl changeNetwork) async {
    if (_network == changeNetwork) return;
    final provider = await _readNetworkProvider(changeNetwork);

    _changeNetwork(changeNetwork, provider: provider);
    await _readAccounts();
    await _saveNetwork(_network);
  }

  Future<void> _changeNetworkApiProvider(ApiProviderService provider) async {
    final currentNetwork = _network;
    final correctProvider = currentNetwork.getProvider(provider);
    _setProvider(currentNetwork, provider: correctProvider);
    await _saveNetworkProvider(currentNetwork, correctProvider);
  }

  Future<NetworkAccountCore> _clenCustomKeysAccount(
      NetworkAccountCore account, List<EncryptedCustomKey> existKeys) async {
    final signers = existKeys.map((e) => e.publicKey).toList();
    List<CryptoAccountAddress> removeList = [];
    for (final a in account.addresses) {
      if (a.keyIndex is Bip32AddressIndex) continue;
      List<String> pubKyes = [];
      if (a.multiSigAccount) {
        final multiSigAccount = a as MultiSigCryptoAccountAddress;
        bool hasImportedKey = multiSigAccount.keyDetails
            .where((element) => element.$2 is ImportedAddressIndex)
            .isEmpty;
        if (hasImportedKey) continue;
      } else {
        pubKyes.addAll(a.signers);
      }
      for (final s in pubKyes) {
        if (signers.contains(s)) continue;
        removeList.add(a);
        break;
      }
    }
    for (final r in removeList) {
      try {
        account.removeAccount(r);
      } on WalletException {
        continue;
      }
    }
    if (removeList.isNotEmpty) {
      await _saveAccount(account);
    }
    return account;
  }
}
