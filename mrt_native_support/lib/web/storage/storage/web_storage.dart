import 'package:mrt_native_support/web/api/mozila/api/storage.dart';
import 'package:mrt_native_support/web/storage/safe_storage/safestorage.dart';
import 'package:mrt_native_support/web/storage/constant/constant.dart';

class WebStorage extends SafeStorage {
  const WebStorage(super._chacha);

  @override
  Future<void> clear() async {
    localStorage.clear();
  }

  @override
  Future<String?> read(String key) async {
    if (key == StorageConst.key) return null;
    final value = localStorage.getItem(key);
    if (value != null) {
      return decrypt(value);
    }
    return null;
  }

  @override
  Future<Map<String, String>> reads(List<String> keys) async {
    keys = keys.where((e) => e != StorageConst.key).toList();
    final items = localStorage.getItems(keys);
    final Map<String, String> decryptedData = {};
    for (final i in items.entries) {
      final decryptValue = decrypt(i.value);
      if (decryptValue != null) {
        decryptedData[i.key] = decryptValue;
      }
    }
    return decryptedData;
  }

  @override
  Future<void> remove(String key) async {
    if (key == StorageConst.key) return;
    localStorage.removeItem(key);
  }

  @override
  Future<void> removes(List<String> keys) async {
    keys = keys.where((e) => e != StorageConst.key).toList();
    localStorage.removeItems(keys);
  }

  @override
  Future<void> save(String key, String value) async {
    if (key == StorageConst.key) return;
    final encryptValue = encrypt(value);
    localStorage.setItem(key, encryptValue);
  }

  @override
  Future<Map<String, String>> all({String? prefix}) async {
    Map<String, String> items = localStorage.getAll();
    items.remove(StorageConst.key);
    if (prefix != null) {
      items = items..removeWhere((k, v) => !k.startsWith(prefix));
    }
    final Map<String, String> decryptedData = {};
    for (final i in items.entries) {
      final decryptValue = decrypt(i.value);
      if (decryptValue != null) {
        decryptedData[i.key] = decryptValue;
      }
    }
    return decryptedData;
  }
}
