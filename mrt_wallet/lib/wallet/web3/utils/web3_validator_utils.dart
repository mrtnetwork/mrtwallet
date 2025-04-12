import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3ValidatorUtils {
  static T isValidMap<K, V, T extends Map<K, V>?>(Object? data,
      {String? name}) {
    if (data == null && null is T) {
      return null as T;
    }
    final toMap = MethodUtils.nullOnException(() => (data as Map).cast<K, V>());
    if (toMap != null) {
      return toMap as T;
    }
    throw Web3RequestExceptionConst.invalidMap(parameterName: name);
  }

  static T onValidate<T>(
      {Object? value,
      required T Function() to,
      required Exception Function() onException,
      bool exceptionWhenIsWrong = true}) {
    if (null is T && value == null) {
      return null as T;
    }
    final result = MethodUtils.nullOnException(to);
    if (result == null) {
      throw onException();
    }
    return result;
  }

  /// if object
  static T parse<T, V>(
      {required T? Function(V value) onParse,
      required Object? value,
      required Web3NetworkRequestMethods method,
      required Web3RequestException Function() onFailed}) {
    if (value == null && null is T) {
      return null as T;
    }
    T? v;
    try {
      v = onParse(value as V);
      if (v == null && null is T) {
        return null as T;
      }
      if (v != null) {
        return v as T;
      }
    } catch (e) {}
    throw onFailed();
  }

  static T praseObject<T, V>(
      {required T? Function(V value) onParse,
      required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (value == null && null is T) {
      return null as T;
    }
    if (value is! V) {
      throw throw Web3RequestExceptionConst.failedToParse(key);
    }
    final obj = MethodUtils.nullOnException(() => onParse(value as V));

    if (obj != null) {
      return obj as T;
    }
    throw throw Web3RequestExceptionConst.failedToParse(key);
  }

  /// check provider value is hex
  static T parseAddress<T>(
      {required T Function(String address) onParse,
      required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json,
      String addressName = ParameterNameConst.ethereumAddress}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (value == null && null is T) {
      return null as T;
    }
    if (value is! String) {
      throw Web3RequestExceptionConst.invalidStringArgrument(addressName);
    }

    T? addr;
    try {
      addr = onParse(value);
    } on Web3RequestException {
      rethrow;
    } catch (e) {}
    if (addr != null) {
      return addr as T;
    }
    throw Web3RequestExceptionConst.invalidAddressArgrument(addressName);
  }

  /// check provider value is hex
  static T parseHex<T>(
      {required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json,
      bool strip0x = true,
      bool required0x = true}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (null is T && value == null) {
      return null as T;
    }
    if (value != null && StringUtils.isHexBytes(value)) {
      if (!required0x || value.startsWith("0x")) {
        if (T == String) {
          if (strip0x) return StringUtils.strip0x(value).toLowerCase() as T;
          return value.toLowerCase() as T;
        }
        return BytesUtils.fromHexString(value) as T;
      }
    }
    throw Web3RequestExceptionConst.invalidHexBytes(key);
  }

  /// check provider value is hex
  static T parseBase64<T extends String?>(
      {required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (null is T && value == null) {
      return null as T;
    }
    final List<int>? toBytes = (value ?? "").isEmpty
        ? <int>[]
        : StringUtils.tryEncode(value, type: StringEncoding.base64) ??
            StringUtils.tryEncode(value, type: StringEncoding.base64UrlSafe);
    if (toBytes != null) {
      if (T == String) {
        if (value!.isEmpty && null is T) return null as T;
        return value as T;
      }
      return toBytes as T;
    }
    throw Web3RequestExceptionConst.invalidBase64Bytes(key);
  }

  static T parseBase58<T extends String?>(
      {required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (null is T && value == null) {
      return null as T;
    }
    final List<int>? toBytes =
        MethodUtils.nullOnException(() => Base58Decoder.decode(value!));
    if (toBytes != null) {
      if (T == String) {
        if (value!.isEmpty && null is T) return null as T;
        return value as T;
      }
      return toBytes as T;
    }
    throw Web3RequestExceptionConst.invalidBase58(key);
  }

  static T isValidList<T extends List?>(Object? data, {String? name}) {
    if (data == null && null is T) {
      return null as T;
    }
    final toList = MethodUtils.nullOnException(() => List.from(data as List));
    if (toList != null) {
      return toList as T;
    }
    throw Web3RequestExceptionConst.invalidMap(parameterName: name);
  }

  static T parseList<T extends List<E>?, E>(
      {required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json,
      int? length,
      bool allowEmpty = false}) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toList = MethodUtils.nullOnException(() => (value as List).cast<E>());
    if (toList != null && (length == null || length == toList.length)) {
      if (toList.isEmpty) {
        if (null is T) {
          return null as T;
        }
        if (allowEmpty) {
          return toList as T;
        }
        throw Web3RequestExceptionConst.emptyList(parameterName: key);
      } else {
        return toList as T;
      }
    }
    throw Web3RequestExceptionConst.invalidList(parameterName: key);
  }

  static T parseMap<T extends Map<String, dynamic>?>({
    required String key,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toMap = MethodUtils.nullOnException(
        () => (value as Map).cast<String, dynamic>());
    if (toMap != null) {
      return toMap as T;
    }
    throw Web3RequestExceptionConst.invalidMap(parameterName: key);
  }

  static T parseString<T extends String?>({
    required String key,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    if (value != null && value is String) {
      return value as T;
    }
    throw Web3RequestExceptionConst.invalidStringArgrument(key);
  }

  static T parseDouble<T extends BigRational?>({
    required String key,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final ratinal = BigRational.tryParseDecimaal(value.toString());
    if (ratinal != null) {
      return ratinal as T;
    }
    throw Web3RequestExceptionConst.invalidNumbers(key);
  }

  /// parse dynamic to bigint
  static T parseBigInt<T extends BigInt?>({
    required String key,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
    bool sign = true,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toBigInt = BigintUtils.tryParse(value);
    if (toBigInt != null) {
      if (sign || !toBigInt.isNegative) return toBigInt as T;
    }
    throw Web3RequestExceptionConst.invalidNumbers(key);
  }

  static String containsOnlyOnce({
    required List<String> keys,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
    required String name,
  }) {
    String? key;
    for (final i in keys) {
      if (json?.containsKey(i) ?? false) {
        if (key != null) {
          key = null;
          break;
        }
        key = i;
      }
    }

    if (key != null) return key;
    throw Web3RequestExceptionConst.invalidObjectKeys(name, keys);
  }

  static T parseInt<T extends int?>(
      {required String key,
      required Web3NetworkRequestMethods method,
      required Map<String, dynamic>? json,
      bool sign = true}) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toInt = IntUtils.tryParse(value);
    if (toInt != null) {
      if (sign || !toInt.isNegative) return toInt as T;
    }
    throw Web3RequestExceptionConst.invalidNumbers(key);
  }

  static T parseBool<T extends bool?>({
    required String key,
    required Web3NetworkRequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }

    if (value is bool) {
      return value as T;
    }
    throw Web3RequestExceptionConst.invalidBoolean(key);
  }

  static T parseParams<T extends Web3MessageCore>(T Function() onParse,
      {Web3RequestException error =
          Web3RequestExceptionConst.invalidMethodArgruments}) {
    try {
      return onParse();
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw error;
    }
  }
}
