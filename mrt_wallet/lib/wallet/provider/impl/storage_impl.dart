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
    await _deleteMultiple(keys: [...walletKeys, ...permissionKeys]);
  }

  Future<void> _setupWalletAccounts(
      List<Chain> accounts, HDWallet wallet) async {
    for (final i in accounts) {
      final toCbor = i.toCbor().toCborHex();
      await _write(key: i.storageId, value: toCbor);
    }
  }

  Future<void> _saveAccount(Chain account) async {
    final toCbor = account.toCbor().toCborHex();
    await _write(key: account.storageId, value: toCbor);
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
        type: CryptoRequestHashingType.md4, dataBytes: applicationId.codeUnits);
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
