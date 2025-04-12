import 'dart:js_interop';

import 'package:blockchain_utils/blockchain_utils.dart'
    show BigintUtils, BytesUtils, StringUtils;
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../../models/models/mrt.dart';

class JsUtils {
  static int compareAddress(String a, String b, String? defaultAddress) {
    if (a == defaultAddress) {
      return -1;
    } else if (b == defaultAddress) {
      return 1;
    }
    return a.compareTo(b);
  }

  static Map<String, dynamic>? toDartMap(JSAny? object) {
    try {
      if (object == null) return null;
      if (object.isA<JSString>()) {
        return StringUtils.toJson<Map<String, dynamic>>(
            (object as JSString).toDart);
      }
      return StringUtils.toJson<Map<String, dynamic>>(jsJson.stringify(object));
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>>? toListOfMap<T>(
    JSAny? object,
  ) {
    try {
      if (object == null) return null;
      if (object.isA<JSString>()) {
        return StringUtils.toJson<List>(object)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return StringUtils.toJson<List>(jsJson.stringify(object))
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static String toEthereumClientId(String clientId) {
    return "ETH_$clientId";
  }

  static String toWalletId(String clientId) {
    return "WALLET_$clientId";
  }

  static int convertInt53(JSInt58 int53) {
    BigInt low = BigInt.from(int53.low);
    BigInt high = BigInt.from(int53.high);
    final BigInt part = (high << 32);
    final BigInt int256 = part | (low & BigInt.from(0xFFFFFFFF));
    if (int53.unsigned) {
      return int256.toUnsigned(53).toInt();
    }

    return int256.toInt();
  }

  static BigInt? parseNumber(JSAny? object) {
    try {
      if (object.isUndefinedOrNull) return null;
      if (object.isA<JSNumber>()) {
        return BigInt.from((object as JSNumber).toDartInt);
      }
      if (object.isA<JSBigInt>()) {
        return BigintUtils.parse(object.toString());
      }
      if (object.isA<JSString>()) {
        return BigintUtils.parse((object as JSString).toDart);
      }
      final n =
          MRTJsObject.as<JSInt58>(object: object, keys: JSInt58.properties);
      if (n != null) {
        return BigInt.from(convertInt53(n));
      }
      return BigintUtils.parse(object.toString());
    } catch (e) {
      return null;
    }
  }

  static JSArray<JSAny> asJSArray(JSAny obj) {
    List<JSAny?> messages = [];
    if (obj.isA<JSArray>()) {
      messages = (obj as JSArray<JSAny?>).toDart;
    } else {
      messages.add(obj);
    }
    return List<JSAny>.from(messages).toJS;
  }

  static String? parseHexString(JSAny? obj, {bool required0x = true}) {
    try {
      if (obj.isA<JSString>()) {
        final hex = (obj as JSString).toDart.toLowerCase();
        if (required0x && !hex.startsWith("0x")) return null;
        final msgBytes = BytesUtils.tryFromHexString(hex);
        if (msgBytes != null) return hex;
        return hex;
      }
    } catch (_) {}
    return null;
  }
}
