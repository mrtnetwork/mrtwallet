part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletStorageImpl on NativeSecureStorageImpl {
  String? _walletChecksum;

  String _toKey(String key) {
    return "$_networkKey$key";
  }

  String get _networkKey =>
      "${StorageConst.walletStorageKey}${_walletChecksum!}_";

  void _setStorageCheckSum(String v) {
    _walletChecksum = v;
  }

  Future<void> _writeWallet(String data, String checksum) async {
    await write(key: StorageConst.walletStorageKey, value: data);
    await write(key: StorageConst.walletChecksum, value: checksum);
  }

  Future<(String, String)?> _readWallet() async {
    final wallet = await read(key: StorageConst.walletStorageKey);
    final checksum = await read(key: StorageConst.walletChecksum);
    if (wallet != null && checksum != null) {
      return (wallet, checksum);
    }
    return null;
  }

  Future<ChainsHandler> _readNetwork() async {
    final selectedNetworkKey = _toKey(StorageConst.walletNetworkKey);
    final networkStr = await read(key: selectedNetworkKey);
    List<ChainHandler> chains = [];
    final keys = await readAll();
    final accounts = keys.keys.where((element) =>
        element.startsWith(_networkKey) && element != selectedNetworkKey);
    for (final i in accounts) {
      try {
        final chain = ChainHandler.fromHex(keys[i]!);
        chains.add(chain);
      } catch (e) {
        continue;
      }
    }
    final appChain =
        ChainsHandler(chains, currentNetwork: int.tryParse(networkStr ?? ""));
    return appChain;
  }

  Future<void> _saveNetworkId(int id) async {
    await write(
        key: _toKey(StorageConst.walletNetworkKey), value: id.toString());
  }

  Future<void> _saveNetwork(ChainHandler chain) async {
    await write(
        key: _toKey(chain.network.value.toString()),
        value: chain.toCbor().toCborHex());
  }

  Future<void> _saveAccount(ChainHandler account) async {
    final toCbor = account.toCbor().toCborHex();
    final accountStorageKey = _toKey(account.network.value.toString());
    await write(key: accountStorageKey, value: toCbor);
  }

  Future<void> _deleteAll() async {
    final keys = await readAll();
    final walletKeys = keys.keys
        .where((element) => element.startsWith(StorageConst.walletStorageKey));
    for (final i in walletKeys) {
      await delete(key: i);
    }
  }
}
