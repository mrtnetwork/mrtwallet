import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

typedef OnValueException = Web3RequestException Function();
typedef OnValidate<T, K> = T Function(K val, String key);
typedef OnRequestString = String Function();

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
      {required T Function(String) onParse,
      required String key,
      required Web3RequestMethods method,
      required Map<String, dynamic>? json}) {
    final value = (json?[key] ?? json?[StrUtils.toSnakeCase(key)])?.toString();
    if (value == null && null is T) {
      return null as T;
    }
    if (value is! String) {
      throw Web3RequestExceptionConst.invalidStringArgrument(
          ParameterNameConst.ethereumAddress);
    }

    final addr = MethodUtils.nullOnException(() => onParse(value));

    if (addr != null) {
      return addr as T;
    }
    throw Web3RequestExceptionConst.invalidAddressArgrument(
        ParameterNameConst.ethereum);
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

  static T parseList<T, E>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toList = MethodUtils.nullOnException(() => List<E>.from(value));
    if (toList != null) {
      if (toList.isEmpty) {
        if (null is T) {
          return null as T;
        }
      } else {
        return toList as T;
      }
    }
    throw Web3RequestExceptionConst.invalidHexBytes(key);
  }

  static T parseMap<T>({
    required String key,
    required Web3RequestMethods method,
    required Map<String, dynamic>? json,
  }) {
    final value = json?[key] ?? json?[StrUtils.toSnakeCase(key)];
    if (null is T && value == null) {
      return null as T;
    }
    final toMap =
        MethodUtils.nullOnException(() => Map<String, dynamic>.from(value));
    if (toMap != null) {
      return toMap as T;
    }
    throw Web3RequestExceptionConst.invalidHexBytes(key);
  }

  static T parseString<T>({
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
  static T parseBigInt<T>({
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

  static T parseInt<T>({
    required String key,
    required Web3RequestMethods method,
    Map<String, dynamic>? json,
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
