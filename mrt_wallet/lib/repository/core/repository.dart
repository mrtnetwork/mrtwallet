part of 'package:mrt_wallet/repository/repository.dart';

mixin BaseRepository {
  String _toKey(String storageId, String key) {
    assert(key.trim().isNotEmpty &&
        key != StorageConst.walletStorageKey &&
        key != StorageConst.walletNetworkKey);
    return "${storageId}_$key";
  }

  Future<void> _write(
      {required String key,
      required String value,
      required String storageId}) async {
    await BaseNativeMEthod.platform.writeSecure(_toKey(storageId, key), value);
  }

  Future<String?> _read(
      {required String key, required String storageId}) async {
    return await BaseNativeMEthod.platform.readSecure(_toKey(storageId, key));
  }
}
