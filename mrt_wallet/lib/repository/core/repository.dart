part of 'package:mrt_wallet/repository/repository.dart';

mixin BaseRepository {
  String get repositoryStorageId;
  String _toKey(String storageId, String key) {
    assert(key.trim().isNotEmpty &&
        key != StorageConst.walletStorageKey &&
        key != StorageConst.walletNetworkKey);
    return "ST_${storageId}_$key";
  }

  Future<void> write({required String key, required String value}) async {
    await BaseNativeMEthod.platform
        .writeSecure(_toKey(repositoryStorageId, key), value);
  }

  Future<String?> read(String key) async {
    return await BaseNativeMEthod.platform
        .readSecure(_toKey(repositoryStorageId, key));
  }
}
