part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletsStoragesManger on WalletStorageWriter, CryptoWokerImpl {
  Future<HDWallets> _readWallet() async {
    final wallet = await _read(key: StorageConst.hdWallets);
    if (wallet == null) {
      return HDWallets.init();
    }
    return HDWallets.fromCborBytesOrObject(hex: wallet);
  }

  Future<void> _writeHdWallet(HDWallets wallet) async {
    await _write(
        key: StorageConst.hdWallets, value: wallet.toCbor().toCborHex());
  }

  Future<void> _removeWalletStorage(HDWallet wallet) async {
    final keys = await _readAll();
    final walletKeys = keys.keys
        .where((element) => element.startsWith(wallet._networkKey))
        .toList();
    final permissionKeys = keys.keys
        .where((element) => element.startsWith(wallet._permissionKey))
        .toList();
    final repositoriesKey = keys.keys
        .where((element) => element.startsWith(wallet._repositoriesKeys))
        .toList();
    await _deleteMultiple(
        keys: [...walletKeys, ...permissionKeys, ...repositoriesKey]);
  }

  Future<void> _setupWalletAccounts(
      List<MRTWalletChainBackup> accounts, HDWallet wallet) async {
    for (final i in accounts) {
      final account = i.chain;
      final toCbor = account.toCbor().toCborHex();
      await account.restoreChainRepositories(i.repositories);
      await _write(key: i.chain.storageId, value: toCbor);
      assert(account.id == wallet._checksum, "invalid account wallet id.");
    }
  }

  Future<void> _removeAccount(Chain account) async {
    await _remove(key: account.storageId);
  }

  Future<List<(String, String)>> _readAccounts(HDWallet wallet) async {
    final keys = await _readAll(prefix: wallet._networkKey);
    return keys.keys
        .where((e) => e.startsWith(wallet._networkKey))
        .map((e) => (e, keys[e]!))
        .toList();
  }

  Future<String?> _readWeb3Permission(
      {required HDWallet wallet, required String applicationId}) async {
    final key = await crypto.generateHashString(
        type: CryptoRequestHashingType.md4,
        dataBytes: applicationId.codeUnits,
        isolate: false);
    return await _read(key: wallet._toPermissionKey(key));
  }

  Future<void> _savePermission(
      {required HDWallet wallet,
      required Web3APPAuthentication permission}) async {
    await _write(
        key: wallet._toPermissionKey(permission.applicationKey),
        value: permission.toCbor().toCborHex());
  }
}
