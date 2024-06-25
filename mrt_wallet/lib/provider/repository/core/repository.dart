part of 'package:mrt_wallet/provider/repository/repository.dart';

mixin BaseRepository {
  String _toKey(String storageId, String key) {
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
