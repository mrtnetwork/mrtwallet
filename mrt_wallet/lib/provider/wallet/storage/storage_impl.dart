part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin WalletStorageImpl on NativeSecureStorageImpl {
  String? _walletChecksum;

  String _toKey(String key) {
    return "$_networkKey$key";
  }

  String get _networkKey =>
      "${StorageKeysConst.walletStorageKey}${_walletChecksum!}_";

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

  Future<AppChains> _readNetwork() async {
    final networkStr =
        await read(key: _toKey(StorageKeysConst.walletNetworkKey));
    List<AppChain> chains = [];
    final keys = await readAll();
    final accounts =
        keys.keys.where((element) => element.startsWith(_networkKey));
    for (final i in accounts) {
      try {
        final chain = AppChain.fromHex(keys[i]!);
        chains.add(chain);
      } catch (e) {
        continue;
      }
    }
    final appChain =
        AppChains(chains, currentNetwork: int.tryParse(networkStr ?? ""));
    return appChain;
  }

  Future<void> _saveNetworkId(int id) async {
    await write(
        key: _toKey(StorageKeysConst.walletNetworkKey), value: id.toString());
  }

  Future<void> _saveNetwork(AppChain chain) async {
    await write(
        key: _toKey(chain.network.value.toString()),
        value: chain.toCbor().toCborHex());
  }

  Future<void> _saveAccount(AppChain account) async {
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
}
