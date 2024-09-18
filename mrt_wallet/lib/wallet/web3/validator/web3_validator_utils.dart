import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3ValidatorConst {
  static const String hexPrefix = "0x";
}

class Web3ValidatorUtils {
  static String? allowWeb3Hex(String? v,
      {Web3RequestException Function()? onFailed}) {
    if (v != null &&
        v.startsWith(Web3ValidatorConst.hexPrefix) &&
        StringUtils.isHexBytes(v)) {
      return v;
    }
    if (onFailed != null) {
      throw onFailed();
    }
    return null;
  }

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

  /// check provider value is hex
  static T parseAddress<T>(
      {required T Function(String address) onParse,
      required String key,
      required Web3RequestMethods method,
      required Map<String, dynamic>? json,
      String addressName = ParameterNameConst.ethereumAddress}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (value == null && null is T) {
      return null as T;
    }
    if (value is! String) {
      throw Web3RequestExceptionConst.invalidStringArgrument(addressName);
    }

    final addr = MethodUtils.nullOnException(() => onParse(value));

    if (addr != null) {
      return addr as T;
    }
    throw Web3RequestExceptionConst.invalidAddressArgrument(addressName);
  }

  /// check provider value is hex
  static T parseHex<T>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (null is T && value == null) {
      return null as T;
    }
    List<int>? toBytes;
    if (value?.startsWith(Web3ValidatorConst.hexPrefix) ?? false) {
      toBytes = BytesUtils.tryFromHexString(value);
    }
    if (toBytes != null) {
      if (T == String) return value as T;
      return toBytes as T;
    }
    throw Web3RequestExceptionConst.invalidHexBytes(key);
  }

  /// check provider value is hex
  static T parseBase64<T extends String?>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (null is T && value == null) {
      return null as T;
    }
    List<int>? toBytes = (value ?? "").isEmpty
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

  static T parseTonCell<T extends Cell?>(
      {required String key,
      required Web3RequestMethods method,
      required Map<String, dynamic>? json}) {
    String? value =
        (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (value?.isEmpty ?? false) {
      value = null;
    }
    if (null is T && value == null) {
      return null as T;
    }
    Cell? cell = MethodUtils.nullOnException(() => Cell.fromBase64(value!));
    if (cell != null) {
      return cell as T;
    }
    throw Web3RequestExceptionConst.invalidBase64Bytes(key);
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

  static T parseList<T extends List<E>?, E>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toList = MethodUtils.nullOnException(() => (value as List).cast<E>());
    if (toList != null) {
      if (toList.isEmpty) {
        if (null is T) {
          return null as T;
        }
      } else {
        return toList as T;
      }
    }
    throw Web3RequestExceptionConst.invalidList(parameterName: key);
  }

  static T parseMap<T extends Map<String, dynamic>?>({
    required String key,
    required Web3RequestMethods method,
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
    required Web3RequestMethods method,
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

  /// parse dynamic to bigint
  static T parseBigInt<T extends BigInt?>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toBigInt = BigintUtils.tryParse(value);
    if (toBigInt != null) {
      return toBigInt as T;
    }
    throw Web3RequestExceptionConst.invalidNumbers(key);
  }

  static T parseInt<T extends int?>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toBigInt = IntUtils.tryParse(value);
    if (toBigInt != null) {
      return toBigInt as T;
    }
    throw Web3RequestExceptionConst.invalidStringArgrument(key);
  }
}
