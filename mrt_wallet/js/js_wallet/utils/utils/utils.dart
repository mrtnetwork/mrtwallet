import 'dart:js_interop';

import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

class JsUtils {
  static int compareAddress(String a, String b, String? defaultAddress) {
    if (a == defaultAddress) {
      return -1;
    } else if (b == defaultAddress) {
      return 1;
    }
    return a.compareTo(b);
  }

  static Map<String, dynamic> convertMap(Map map) {
    map.forEach((key, value) {
      if (value is Map) {
        map[key] = convertMap(value);
      }
    });
    return Map<String, dynamic>.from(map);
  }

  static Map<String, dynamic> toMap(dynamic object, {Object? error}) {
    // if (obj == null) return null;
    try {
      if (object is JSAny) {
        try {
          if (!object.isA<JSString>()) {
            object = jsJson.stringify(object);
          }
        } catch (_) {}
      }
      if (object is! String) {
        object = StringUtils.fromJson(object);
      }
      return StringUtils.toJson(object);
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
