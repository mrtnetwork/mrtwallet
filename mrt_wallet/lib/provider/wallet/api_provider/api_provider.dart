part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin NetworkApiProviderImpl on WalletStorageImpl {
  final Map<AppNetworkImpl, NetworkApiProvider> _providers = {};

  NetworkApiProvider _buildApiProvider(AppNetworkImpl network,
      {ApiProviderService provider = ApiProviderService.mempool}) {
    switch (network) {
      case AppBitcoinNetwork.bitcoinMainnet:
      case AppBitcoinNetwork.bitcoinTestnet:
      case AppBitcoinNetwork.litecoinMainnet:
      case AppBitcoinNetwork.dogecoinMainnet:
      case AppBitcoinNetwork.dashMainnet:
        final btcNetwork =
            (network as AppBitcoinNetwork).coinParam.transacationNetwork;
        final serviceProvider = ApiProviderTracker(provider: provider);
        final api = provider == ApiProviderService.mempool
            ? ApiProvider.fromMempool(
                btcNetwork, BitcoinApiService(serviceProvider))
            : ApiProvider.fromBlocCypher(
                btcNetwork, BitcoinApiService(serviceProvider));
        return BitcoinApiProvider(
            provider: api, network: network, serviceProvider: serviceProvider);
      default:
        throw WalletExceptionConst.incorrectNetwork;
    }
  }

  ApiProviderTracker currentProvider(AppNetworkImpl network) =>
      _providers[network]!.serviceProvider;
  T getBitcoinNetworkApiProvider<T extends NetworkApiProvider>(
      AppBitcoinNetwork network,
      {ApiProviderService provider = ApiProviderService.mempool}) {
    if (_providers.containsKey(network) &&
        (_providers[network] as BitcoinApiProvider).serviceProvider.provider ==
            provider) {
      return (_providers[network]! as T);
    }

    return _buildApiProvider(network, provider: provider) as T;
  }

  T getNetworkApiProvider<T extends NetworkApiProvider>(
      AppNetworkImpl network) {
    _providers[network] ??= _buildApiProvider(network);
    return _providers[network]! as T;
  }

  void _setProvider(AppNetworkImpl network, {ApiProviderService? provider}) {
    if (provider != null &&
        _providers[network]?.serviceProvider.provider == provider) return;
    _providers[network] =
        _buildApiProvider(network, provider: network.getProvider(provider));
  }

  Future<void> _updateAccountBalance(NetworkAccountCore? account) async {
    if (account == null) return;
    await getNetworkApiProvider(account.network).updateBalance(account.address);
    await _saveAccount(account);
  }

  Future<void> _updateAccountsBalance(NetworkAccountCore? account) async {
    if (account == null) return;
    final provider = getNetworkApiProvider(account.network);
    for (final i in account.addresses) {
      await provider.updateBalance(i).catchError((e) {
        return null;
      });
    }
    await _saveAccount(account);
  }
}
