part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletStorageManger on WalletStorageWriter {
  HDWallet get _wallet;
  Future<void> _updateWallet(HDWallet wallet, bool? asDefaultWallet);

  Future<void> _updateWalletData(String data) async {
    await _updateWallet(_wallet._updateData(data), null);
  }

  Future<void> _saveNetworkId(int id) async {
    await _updateWallet(_wallet.updateNetwork(id), null);
  }

  Future<void> _saveAccount(ChainHandler account) async {
    final toCbor = account.toCbor().toCborHex();
    final accountStorageKey = _wallet._toKey(account.network.value.toString());
    await _write(key: accountStorageKey, value: toCbor);
  }

  Future<List<(String, String)>> _readAccounts() async {
    final keys = await _readAll();
    return keys.keys
        .where((e) => e.startsWith(_wallet._networkKey))
        .map((e) => (e, keys[e]!))
        .toList();
  }

  // Future<void> _saveAccounts(List<ChainHandler> account) async {
  //   for (final i in account) {
  //     await _saveAccount(i);
  //   }
  // }
}
