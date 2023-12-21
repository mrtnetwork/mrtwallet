import 'package:blockchain_utils/blockchain_utils.dart';

extension ExtractCborList on CborListValue {
  T? getIndex<T>(int index) {
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
}
