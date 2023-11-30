part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletNetworkImpl
    on
        NetworkApiProviderImpl,
        WalletCryptoImpl,
        WalletStorageImpl,
        MasterKeyImpl {
  AppNetworkImpl _network = AppBitcoinNetwork.bitcoinTestnet;
  AppNetworkImpl get network => _network;
  void _changeNetwork(AppNetworkImpl newNetwork,
      {ApiProviderService? provider}) {
    _setProvider(newNetwork, provider: provider);
    _network = newNetwork;
  }

  NetworkAccountCore? _account;
  bool get haveAddress => _account?.haveAddress ?? false;
  NetworkAccountCore get networkAccount => _account!;

  Future<void> _switchAccount(CryptoAddress account) async {
    final acc = networkAccount;
    acc.switchAccount(account);
    await _saveAccount(acc);
  }

  Future<void> _removeAccount(CryptoAddress account) async {
    final acc = networkAccount;
    acc.removeAccount(account);
    await _saveAccount(acc);
  }

  Future<void> _readAccounts() async {
    _account = await _readNetworkAccout(_network);
  }

  Future<void> _addNewAccountToNetwork(
    NewAccountParams accountParams,
    List<int> publicKey,
  ) async {
    final currentAccount = _account!;
    currentAccount.addNewAddress(publicKey, accountParams);
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
}
