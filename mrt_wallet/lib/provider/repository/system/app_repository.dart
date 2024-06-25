part of 'package:mrt_wallet/provider/repository/repository.dart';

mixin APPRepository on BaseRepository {
  String get _appStorageId => StorageKeysConst.app;

  Future<void> saveAppSetting(AppSetting setting) async {
    await _write(
        key: StorageKeysConst.appSetting,
        value: setting.toCbor().toCborHex(),
        storageId: _appStorageId);
  }

  Future<AppSetting> getAppSetting() async {
    final data =
        await _read(key: StorageKeysConst.appSetting, storageId: _appStorageId);
    return AppSetting.fromHex(data);
  }
}
