part of 'package:mrt_wallet/repository/repository.dart';

mixin BaseRepository {
  String get repositoryStorageId;
  String _toKey(String storageId, String key) {
    assert(key.trim().isNotEmpty && key != StorageConst.walletStorageKey);
    return "ST_${storageId}_$key";
  }

  Future<void> write({required String key, required String value}) async {
    await AppNativeMethods.platform
        .writeSecure(_toKey(repositoryStorageId, key), value);
  }

  Future<String?> read(String key) async {
    return await AppNativeMethods.platform
        .readSecure(_toKey(repositoryStorageId, key));
  }
}
