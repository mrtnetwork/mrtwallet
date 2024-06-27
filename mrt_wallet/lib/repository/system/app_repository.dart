part of 'package:mrt_wallet/repository/repository.dart';

mixin APPRepository on BaseRepository {
  String get _appStorageId => StorageConst.app;

  Future<void> saveAppSetting(APPSetting setting) async {
    await _write(
        key: StorageConst.appSetting,
        value: setting.toCbor().toCborHex(),
        storageId: _appStorageId);
  }

  Future<APPSetting> getAppSetting() async {
    final data =
        await _read(key: StorageConst.appSetting, storageId: _appStorageId);
    return APPSetting.fromHex(data);
  }
}
