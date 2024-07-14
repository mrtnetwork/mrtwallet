part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletsStoragesManger on WalletStorageWriter {
  Future<HDWallets> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return _readLegacyWallet();
    }
    return HDWallets.fromCborBytesOrObject(hex: wallet);
  }

  Future<void> _writeHdWallet(HDWallets wallet) async {
    await _write(
        key: StorageConst.hdWallets, value: wallet.toCbor().toCborHex());
  }

  Future<HDWallets> _readLegacyWallet() async {
    final wallet = await _read(key: StorageConst.walletStorageKey);
    final checksum = await _read(key: StorageConst.walletChecksum);
    final network = await _read(key: StorageConst.walletNetworkKey);
    if (wallet != null && checksum != null) {
      final legacyWallet = HDWallets.legacy(
          checksum: checksum,
          data: wallet,
          network: int.tryParse(network ?? ""));
      await _writeHdWallet(legacyWallet);
      await _removeLegacyWallet();
      return legacyWallet;
    }
    return HDWallets.init();
  }

  Future<void> _removeLegacyWallet() async {
    await _delete(key: StorageConst.walletStorageKey);
    await _delete(key: StorageConst.walletChecksum);
    await _delete(key: StorageConst.walletNetworkKey);
  }

  Future<void> _removeWalletStorage(HDWallet wallet) async {
    final keys = await _readAll();
    final walletKeys = keys.keys
        .where((element) => element.startsWith(wallet._networkKey))
        .toList();
    await _deleteMultiple(keys: walletKeys);
  }

  Future<void> _setupWalletAccounts(
      List<ChainHandler> accounts, HDWallet wallet) async {
    for (final i in accounts) {
      final toCbor = i.toCbor().toCborHex();
      final accountStorageKey = wallet._toKey(i.network.value.toString());
      await _write(key: accountStorageKey, value: toCbor);
    }
  }
}
