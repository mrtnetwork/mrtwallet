part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin WalletStorageWriter {
  final Map<String, String> _memoryStorage = {};
  bool get useMemoryStorage;
  Future<String?> _read({required String key}) async {
    if (useMemoryStorage) {
      return _memoryStorage[key];
    }
    return await BaseNativeMEthod.platform.readSecure(key);
  }

  Future<void> _write({required String key, required String value}) async {
    if (useMemoryStorage) {
      _memoryStorage[key] = value;
      return;
    }
    await BaseNativeMEthod.platform.writeSecure(key, value);
  }

  Future<void> _remove({required String key}) async {
    if (useMemoryStorage) {
      _memoryStorage.remove(key);
      return;
    }
    await BaseNativeMEthod.platform.removeSecure(key);
  }

  Future<Map<String, String>> _readAll({String? prefix}) async {
    if (useMemoryStorage) {
      if (prefix != null) {
        return Map<String, String>.fromEntries(
            _memoryStorage.entries.where((e) => e.key.startsWith(prefix)));
      }
      return Map<String, String>.from(_memoryStorage);
    }
    return await BaseNativeMEthod.platform.readAllSecure(prefix: prefix);
  }

  Future<bool> _deleteMultiple({required List<String> keys}) async {
    if (useMemoryStorage) {
      for (final i in keys) {
        _memoryStorage.remove(i);
      }
      return true;
    }
    return await BaseNativeMEthod.platform.removeMultipleSecure(keys);
  }
}
