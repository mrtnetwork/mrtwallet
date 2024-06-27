import 'package:blockchain_utils/crypto/crypto/crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';

class QuickBytesUtils {
  static String ensureIsHex(String data) {
    try {
      BytesUtils.fromHexString(data);
      return data;
    } catch (e) {
      return BytesUtils.toHexString(StringUtils.encode(data));
    }
  }

  static String ensureHexWithLength(String data, int strWidth) {
    final toHex = BytesUtils.toHexString(StringUtils.encode(data));
    final hex = toHex.padLeft(strWidth, "0");
    return hex;
  }

  static String hexToString(String hex) {
    try {
      final utf8Bytes = BytesUtils.fromHexString(hex);
      final toString = StringUtils.decode(utf8Bytes);
      return toString;
    } catch (e) {
      return hex;
    }
  }

  static String? ensureIsHash256(String? hex) {
    if (hex == null) return null;
    try {
      final toBytes = BytesUtils.fromHexString(hex);
      if (toBytes.length == SHA256.digestLength) {
        return hex;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
