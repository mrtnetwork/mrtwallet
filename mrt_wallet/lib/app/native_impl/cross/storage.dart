import 'package:mrt_wallet/app/native_impl/core/core.dart';

mixin NativeSecureStorageImpl {
  Future<String?> read({required String key}) async {
    return await AppNativeMethods.platform.readSecure(key);
  }

  Future<void> write({required String key, required String value}) async {
    await AppNativeMethods.platform.writeSecure(key, value);
  }

  Future<void> deleteAll() async {
    await AppNativeMethods.platform.removeAllSecure();
  }

  Future<void> delete({required String key}) async {
    await AppNativeMethods.platform.removeSecure(key);
  }

  Future<Map<String, String>> readAll() async {
    return await AppNativeMethods.platform.readAllSecure();
  }

  Future<bool> deleteMultiple({required List<String> keys}) async {
    return await AppNativeMethods.platform.removeMultipleSecure(keys);
  }
}
