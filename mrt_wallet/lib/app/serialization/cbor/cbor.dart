import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain/on_chain.dart';

mixin CborSerializable {
  CborTagValue toCbor();
  static CborTagValue toTagValue<T extends CborObject>(List<int> bytes,
      {List<int>? tags}) {
    final cbor = CborObject.fromCbor(bytes);
    if (cbor is! CborTagValue) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    if (tags != null && !BytesUtils.bytesEqual(cbor.tags, tags)) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    return cbor;
  }

  static T decodeCborTags<T extends CborObject>(
      List<int>? cborBytes, CborObject? object, List<int>? tags) {
    assert(cborBytes != null || object != null,
        "cbor bytes or cbor object must not be null");

    final cbor = object ?? CborObject.fromCbor(cborBytes!);

    return validateCbor(cbor, tags);
  }

  static T cborTagValue<T extends CborObject>({
    List<int>? cborBytes,
    CborObject? object,
    String? hex,
    List<int>? tags,
  }) {
    assert(cborBytes != null || object != null || hex != null,
        "cbor bytes or cbor object must not be null");
    if (object == null) {
      cborBytes ??= BytesUtils.tryFromHexString(hex);
      if (cborBytes == null) {
        throw WalletException(
            "decoding cbor required object, bytes or hex. no value provided for decoding.");
      }
      object = CborObject.fromCbor(cborBytes);
    }

    return validateCbor(object, tags);
  }

  static T validateCbor<T extends CborObject>(
      CborObject cbor, List<int>? tags) {
    if (cbor is! CborTagValue || cbor.value is! T) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    if (tags != null && !BytesUtils.bytesEqual(cbor.tags, tags)) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    return cbor.value;
  }

  static T decode<T extends CborObject>(
      {List<int>? cborBytes, CborObject? object, String? hex}) {
    try {
      if (object == null) {
        cborBytes ??= BytesUtils.tryFromHexString(hex);
        if (cborBytes == null) {
          throw WalletException(
              "decoding cbor required object, bytes or hex. no value provided for decoding.");
        }
        object = CborObject.fromCbor(cborBytes);
      }
      if (object is! T) {
        throw WalletException.invalidArgruments(["$T" "${object.runtimeType}"]);
      }
      return object;
    } catch (e) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
  }
}
typedef OnKeyValue<T> = T Function(CborObject);

extension ExtractCborMap on CborMapValue {
  Map<K, V> toMap<K, V>() {
    try {
      final Map<CborObject, CborObject> cborMap = value.cast();
      final entrries = cborMap.entries
          .map((e) => MapEntry<K, V>(e.key.getValue(), e.value.getValue()));
      return Map<K, V>.fromEntries(entrries);
    } catch (e) {
      rethrow;
    }
  }

  Map<K, V> generateMap<K, V>(OnKeyValue<K> onKey, OnKeyValue<V> onValue) {
    final Map<CborObject, CborObject> cborMap = value.cast();
    final entrries = cborMap.entries
        .map((e) => MapEntry<K, V>(onKey(e.key), onValue(e.value)));
    return Map<K, V>.fromEntries(entrries);
  }
}

extension ExtractCborList on CborListValue {
  T elementAt<T>(int index) {
    if (index > value.length - 1) return null as T;
    final cborValue = value[index];
    final dynamic v;
    if (T == CborMapValue) {
      if (cborValue is CborMapValue) {
        return cborValue as T;
      }
      return null as T;
    }
    if (cborValue is CborObject) {
      v = cborValue.value;
    } else {
      v = cborValue;
    }
    if (v is! T) return null as T;
    return v;
  }

  T elemetAs<T>(int index) {
    if (index > value.length - 1) {
      if (null is T) return null as T;
      throw WalletExceptionConst.invalidSerializationData;
    }
    try {
      CborObject? cborValue = value[index];
      if (null is T && cborValue == const CborNullValue()) {
        return null as T;
      }
      if (cborValue is T) {
        return cborValue as T;
      }
      return cborValue!.value as T;
    } catch (e) {
      throw WalletExceptionConst.invalidSerializationData;
    }
  }

  List<T> cast<T>() {
    return [for (int i = 0; i < value.length; i++) elementAt<T>(i)];
  }

  List<T> castValue<T>() {
    return [for (int i = 0; i < value.length; i++) elemetAs<T>(i)];
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
  T getElement<T extends CborObject?>(int index) {
    if (index >= value.length) {
      if (null is T) return null as T;
      throw WalletExceptionConst.invalidSerializationData;
    }
    final CborObject obj = value.elementAt(index);
    if (null is T && obj == const CborNullValue()) {
      return null as T;
    }
    if (obj is T) return obj as T;
    throw WalletExceptionConst.invalidSerializationData;
  }
}

extension QuickCbor on CborTagValue {
  /// Converts the value of the [CborObject] to the specified type [E] using the provided function [toe].
  ///
  /// Throws a [WalletException] if the value cannot be converted to type [T].
  E to<E, T extends CborObject>(E Function(CborObject e) toe) {
    if (this is T) {
      return toe(this as T);
    }
    if (value is! T) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    return toe(value as T);
  }
}

extension QuickCborTag on CborTagValue {
  CborListValue get getList {
    if (value is! CborListValue) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    return value;
  }

  T valueAs<T extends CborObject>() {
    if (value is! T) {
      throw WalletExceptionConst.invalidSerializationData;
    }
    return value;
  }
}
