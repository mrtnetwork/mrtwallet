import 'package:blockchain_utils/utils/string/string.dart';

class JsUtils {
  static Map<K, V> toMap<K, V>(dynamic object, {Object? error}) {
    // if (obj == null) return null;
    try {
      if (object is String) {
        object = StringUtils.toJson<Map>(object);
      }
      return Map<K, V>.from(object);
    } catch (e) {
      if (error != null) throw error;
      rethrow;
    }
  }

  static List<T> toList<T>(dynamic object, {Object? error}) {
    try {
      if (object is String) {
        object = StringUtils.toJson<List>(object);
      }
      return List<T>.from(object);
    } catch (e) {
      if (error != null) throw error;
      rethrow;
    }
  }

  static String toEthereumClientId(String clientId) {
    return "ETH_$clientId";
  }

  static String toWalletId(String clientId) {
    return "WALLET_$clientId";
  }
}
