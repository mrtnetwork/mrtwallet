import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

extension ExtractCborList on CborListValue {
  T? elementAt<T>(int index) {
    if (index > value.length - 1) return null;
    final cborValue = value[index];
    final dynamic v;
    if (cborValue is CborObject) {
      v = cborValue.value;
    } else {
      v = cborValue;
    }
    if (v is! T) return null;
    return v;
  }

  CborTagValue? getCborTag(int index) {
    if (index > value.length - 1) return null;
    final cborValue = value[index];
    if (cborValue is! CborObject) return null;
    if (cborValue is CborTagValue) return cborValue;
    if (cborValue.value is CborTagValue) return cborValue.value;
    return null;
  }

  int? getInt(int index) {
    if (index > value.length - 1) return null;
    final cborValue = value[index];
    int? v;
    if (cborValue is CborIntValue) {
      v = cborValue.value;
    } else if (cborValue is int) {
      v = cborValue;
    }
    return v;
  }

  String? getString(int index) {
    if (index > value.length - 1) return null;
    final cborValue = value[index];
    String? v;
    if (cborValue is CborStringValue) {
      v = cborValue.value;
    } else if (cborValue is String) {
      v = cborValue;
    }
    return v;
  }

  /// Gets the value at the specified [index] in the [CborListValue].
  ///
  /// If [index] is out of bounds and [T] is nullable, returns null. Otherwise, throws a [WalletException].
  T getElement<T>(int index) {
    if (index >= value.length) {
      if (null is T) return null as T;
      throw WalletException("Index out of bounds.");
    }

    final CborObject obj = value.elementAt(index);
    if (null is T && obj == const CborNullValue()) {
      return null as T;
    }
    if (obj is T) return obj as T;
    if (obj.value is! T) {
      throw WalletException("Failed to cast value.");
    }
    return obj.value;
  }
}

extension QuickCbor on CborObject {
  /// Converts the value of the [CborObject] to the specified type [E] using the provided function [toe].
  ///
  /// Throws a [WalletException] if the value cannot be converted to type [T].
  E to<E, T>(E Function(T e) toe) {
    if (this is T) {
      return toe(this as T);
    }
    if (value is! T) {
      throw WalletException("Failed to cast value.");
    }
    return toe(value as T);
  }
}

extension QuickCborTag on CborTagValue {
  CborListValue get getList {
    if (value is! CborListValue) {
      throw WalletException("Failed to cast value.");
    }
    return value;
  }
}
