part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletStorageImpl on NativeSecureStorageImpl {
  String? _walletChecksum;

  String _toKey(String key) {
    return "${StorageKeysConst.walletStorageKey}${_walletChecksum!}_$key";
  }

  String _toProviderKey(int networkId) {
    return "${StorageKeysConst.walletStorageKey}${_walletChecksum!}_${StorageKeysConst.apiProviderKey}_$networkId";
  }

  void _setStorageCheckSum(String v) {
    _walletChecksum = v;
  }

  Future<void> _writeWallet(String data, String checksum) async {
    await write(key: StorageKeysConst.walletStorageKey, value: data);
    await write(key: StorageKeysConst.walletChecksum, value: checksum);
  }

  Future<(String, String)?> _readWallet() async {
    final wallet = await read(key: StorageKeysConst.walletStorageKey);
    final checksum = await read(key: StorageKeysConst.walletChecksum);
    if (wallet != null && checksum != null) {
      return (wallet, checksum);
    }
    return null;
  }

  Future<(AppNetworkImpl, ApiProviderService)?> _readNetwork() async {
    try {
      final networkStr =
          await read(key: _toKey(StorageKeysConst.walletNetworkKey));

      final networkId = int.parse(networkStr!);
      final network = AppNetworkImpl.fromValue(networkId);
      final service = await _readNetworkProvider(network);
      return (network, service);
    } catch (e) {
      return null;
    }
  }

  Future<ApiProviderService> _readNetworkProvider(
      AppNetworkImpl networkImpl) async {
    try {
      final provider = await read(key: _toProviderKey(networkImpl.value));
      final service = ApiProviderService.fromServiceName(provider!);
      return networkImpl.getProvider(service);
    } catch (e) {
      return networkImpl.getProvider();
    }
  }

  Future<void> _saveNetwork(AppNetworkImpl network) async {
    await write(
        key: _toKey(StorageKeysConst.walletNetworkKey),
        value: "${network.value}");
  }

  Future<void> _saveNetworkProvider(
      AppNetworkImpl network, ApiProviderService provider) async {
    final serviceName = network.getProvider(provider).serviceName;
    final providerKey = _toProviderKey(network.value);
    await write(key: providerKey, value: serviceName);
  }

  Future<void> _saveAccount(NetworkAccountCore account) async {
    final toCbor = account.toCbor().toCborHex();
    final accountStorageKey = _toKey(account.network.value.toString());
    await write(key: accountStorageKey, value: toCbor);
  }

  Future<void> _deleteAll() async {
    final keys = await readAll();
    final walletKeys = keys.keys.where(
        (element) => element.startsWith(StorageKeysConst.walletStorageKey));
    for (final i in walletKeys) {
      await delete(key: i);
    }
  }

  Future<NetworkAccountCore> _readNetworkAccout(AppNetworkImpl network) async {
    try {
      final accounts = await read(key: _toKey(network.value.toString()));
      return _toNetworkAccount(network, accounts!);
    } catch (e) {
      return _createNetworkAccount(network);
    }
  }

  Bip32NetworkAccount _toNetworkAccount(
      AppNetworkImpl network, String account) {
    switch (network.runtimeType) {
      case AppXRPNetwork:
        return Bip32NetworkAccount<BigInt, BigRational, XRPAddress>.fromHex(
            account);
      default:
        return Bip32NetworkAccount<BigInt, BigInt, BitcoinAddress>.fromHex(
            account);
    }
  }

  Bip32NetworkAccount _createNetworkAccount(AppNetworkImpl network) {
    switch (network.runtimeType) {
      case AppXRPNetwork:
        return Bip32NetworkAccount<BigInt, BigRational, XRPAddress>.setup(
            network);
      default:
        return Bip32NetworkAccount<BigInt, BigInt, BitcoinAddress>.setup(
            network);
    }
  }

  Future<List<NetworkAccountCore>> _readAllAccounts() async {
    final List<NetworkAccountCore> accounts = [];
    for (final i in AppNetworkImpl.networks) {
      final acc = await _readNetworkAccout(i);
      if (!acc.haveAddress) continue;
      accounts.add(acc);
    }
    return List.unmodifiable(accounts);
  }
}
