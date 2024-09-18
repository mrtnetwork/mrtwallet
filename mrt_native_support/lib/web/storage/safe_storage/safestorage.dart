import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';

import 'package:mrt_native_support/web/api/api.dart';
import 'package:mrt_native_support/web/storage/storage/chrome_storage.dart';
import 'package:mrt_native_support/web/storage/storage/web_storage.dart';
import 'package:mrt_native_support/web/storage/constant/constant.dart';

import 'storage_item.dart';

class SafestorageUtils {
  static String encrypt(List<int> value, ChaCha20Poly1305 chacha) {
    final nonce = QuickCrypto.generateRandom(8);
    final encryptedValue = chacha.encrypt(nonce, value);
    final storage = StorageItem(nonce: nonce, encryptedValue: encryptedValue);
    return storage.toCbor().toCborHex();
  }

  static String? decrypt(String encryptedValue, ChaCha20Poly1305 chacha) {
    try {
      final item = StorageItem.fromStorage(encryptedValue);
      final decode = chacha.decrypt(item.nonce, item.encryptedValue);
      return StringUtils.tryDecode(decode);
    } catch (e) {
      return null;
    }
  }

  static (String, ChaCha20Poly1305) _generateKey() {
    final newKey = QuickCrypto.generateRandom(32);
    return (BytesUtils.toHexString(newKey), ChaCha20Poly1305(newKey));
  }

  static Map<String, List<int>> _legacy(
      Iterable<MapEntry<String, String>> items, String legacyKey) {
    const String keyPrefix = "${StorageConst.legacyKey}.";
    const int keyLength = keyPrefix.length;
    final Map<String, List<int>> migratedValues = {};
    final gcm =
        GCM(AES(StringUtils.encode(legacyKey, type: StringEncoding.base64)));

    for (final i in items) {
      final correctKey = i.key.substring(keyLength);
      final parts = i.value.split(".");
      if (parts.length != 2) continue;
      try {
        final nonce = StringUtils.encode(parts[0], type: StringEncoding.base64);
        final encryptedValue =
            StringUtils.encode(parts[1], type: StringEncoding.base64);
        final decode = gcm.decrypt(nonce, encryptedValue);
        if (decode == null) continue;
        migratedValues[correctKey] = decode;
      } catch (e) {
        continue;
      }
    }
    return migratedValues;
  }

  static Future<String?> _key() async {
    if (isExtension) {
      return await extension.storage.local.getStorage_(StorageConst.key);
    }
    return localStorage.getItem(StorageConst.key);
  }

  static Future<ChaCha20Poly1305> migrateLegacy() async {
    final String? key = await _key();
    if (key != null) {
      return ChaCha20Poly1305(BytesUtils.fromHexString(key));
    }
    final generateKey = _generateKey();
    final ChaCha20Poly1305 chacha = generateKey.$2;
    if (isExtension) {
      await extension.storage.local
          .setStorage_(StorageConst.key, generateKey.$1);
      return chacha;
    }
    final legacyKey = localStorage.getItem(StorageConst.legacyKey);
    if (legacyKey == null) {
      localStorage.setItem(StorageConst.key, generateKey.$1);
      return chacha;
    }
    const String keyPrefix = "${StorageConst.legacyKey}.";
    final allData = localStorage.getAll();
    final items = List<MapEntry<String, String>>.unmodifiable(allData.entries
        .where((e) =>
            e.key.startsWith(keyPrefix) && e.key != StorageConst.legacyKey));
    localStorage.clear();
    localStorage.setItem(StorageConst.key, generateKey.$1);
    if (items.isNotEmpty) {
      final legacyData = _legacy(items, legacyKey);
      for (final i in legacyData.entries) {
        final encryptedValue = encrypt(i.value, chacha);
        localStorage.setItem(i.key, encryptedValue);
      }
    }
    return chacha;
  }
}

abstract class SafeStorage {
  final ChaCha20Poly1305 _chacha;
  const SafeStorage(this._chacha);
  static Future<SafeStorage> init() async {
    final key = await SafestorageUtils.migrateLegacy();
    if (isExtension) {
      return ChromeStorage(key);
    }
    return WebStorage(key);
  }

  Future<void> clear();
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<Map<String, String>> reads(List<String> keys);
  Future<Map<String, String>> all({String? prefix});
  Future<void> remove(String key);
  Future<void> removes(List<String> keys);
  String encrypt(String value) {
    return SafestorageUtils.encrypt(StringUtils.encode(value), _chacha);
  }

  String? decrypt(String encryptedValue) {
    return SafestorageUtils.decrypt(encryptedValue, _chacha);
  }
}
