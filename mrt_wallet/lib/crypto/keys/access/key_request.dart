import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class AccessCryptoPrivateKeysRequest with CborSerializable {
  final List<AccessCryptoPrivateKeyRequest> indexes;
  AccessCryptoPrivateKeysRequest(List<AccessCryptoPrivateKeyRequest> indexes)
      : indexes = List<AccessCryptoPrivateKeyRequest>.unmodifiable(indexes);
  factory AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeysRequest);
    final List<AccessCryptoPrivateKeyRequest> indexes = cbor.value
        .map((e) => AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(obj: e))
        .toList();
    return AccessCryptoPrivateKeysRequest(indexes);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(indexes.map((e) => e.toCbor()).toList(),
        CryptoKeyConst.accessPrivateKeysRequest);
  }
}

class AccessCryptoPrivateKeyRequest with CborSerializable {
  final AddressDerivationIndex index;
  final int maxLevel;

  const AccessCryptoPrivateKeyRequest({required this.index, this.maxLevel = 5});

  factory AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPrivateKeyRequest);

    return AccessCryptoPrivateKeyRequest(
        index: AddressDerivationIndex.fromCborBytesOrObject(
            obj: cbor.getCborTag(0)),
        maxLevel: cbor.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([index.toCbor(), maxLevel]),
        CryptoKeyConst.accessPrivateKeyRequest);
  }
}
