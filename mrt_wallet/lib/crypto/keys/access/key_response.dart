import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'key_data.dart';

class CryptoPrivateKeysResponse with CborSerializable {
  final List<CryptoPrivateKeyData> keys;
  CryptoPrivateKeysResponse(List<CryptoPrivateKeyData> keys)
      : keys = List<CryptoPrivateKeyData>.unmodifiable(keys);
  factory CryptoPrivateKeysResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeysRequest);
    final List<CryptoPrivateKeyData> indexes = cbor.value
        .map((e) => CryptoPrivateKeyData.fromCborBytesOrObject(obj: e))
        .toList();
    return CryptoPrivateKeysResponse(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(keys.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPrivateKeysRequest);
  }
}

class CryptoPrivateKeyResponse with CborSerializable {
  final CryptoPrivateKeyData key;
  CryptoPrivateKeyResponse(this.key);
  factory CryptoPrivateKeyResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeysRequest);
    return CryptoPrivateKeyResponse(
        CryptoPrivateKeyData.fromCborBytesOrObject(obj: cbor.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([key.toCbor()]),
        CryptoKeyConst.accessPrivateKeysRequest);
  }
}

class CryptoPublicKeysResponse with CborSerializable {
  final List<CryptoPublicKeyData> keys;
  CryptoPublicKeysResponse(List<CryptoPublicKeyData> keys)
      : keys = List<CryptoPublicKeyData>.unmodifiable(keys);
  factory CryptoPublicKeysResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPublicKeysRequest);
    final List<CryptoPublicKeyData> indexes = cbor.value
        .map((e) => CryptoPublicKeyData.fromCborBytesOrObject(obj: e))
        .toList();
    return CryptoPublicKeysResponse(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(keys.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPublicKeysRequest);
  }
}

class CryptoPublicKeyResponse with CborSerializable {
  final CryptoPublicKeyData key;
  CryptoPublicKeyResponse(this.key);
  factory CryptoPublicKeyResponse.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPublicKeyRequest);
    return CryptoPublicKeyResponse(
        CryptoPublicKeyData.fromCborBytesOrObject(obj: cbor.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([key.toCbor()]),
        CryptoKeyConst.accessPublicKeyRequest);
  }
}
