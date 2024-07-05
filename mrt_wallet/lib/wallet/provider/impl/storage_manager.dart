part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletStorageWriter {
  Future<String?> _read({required String key}) async {
    return await BaseNativeMEthod.platform.readSecure(key);
  }

  Future<void> _write({required String key, required String value}) async {
    await BaseNativeMEthod.platform.writeSecure(key, value);
  }

  Future<void> _deleteAll() async {
    await BaseNativeMEthod.platform.removeAllSecure();
  }

  Future<void> _delete({required String key}) async {
    await BaseNativeMEthod.platform.removeSecure(key);
  }

  Future<Map<String, String>> _readAll() async {
    return await BaseNativeMEthod.platform.readAllSecure();
  }

  Future<bool> _deleteMultiple({required List<String> keys}) async {
    return await BaseNativeMEthod.platform.removeMultipleSecure(keys);
  }
}
