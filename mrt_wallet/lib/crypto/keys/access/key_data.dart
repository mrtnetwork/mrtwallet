import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_private_key.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/access/public_key_response.dart';
// import 'package:mrt_wallet/wroker/worker.dart';

abstract class CryptoKeyData with CborSerializable {
  abstract final String keyName;
}

abstract class CryptoPublicKeyData
    with CborSerializable
    implements CryptoKeyData {
  const CryptoPublicKeyData();
  abstract final String? extendedKey;
  abstract final String comprossed;
  abstract final String? chainCode;
  abstract final String? uncomprossed;
  factory CryptoPublicKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        cbor.tags, CryptoKeyConst.accessPubliKeyResponse)) {
      return PublicKeyData.fromCborBytesOrObject(obj: cbor);
    }
    return AdaLegacyPublicKeyData.fromCborBytesOrObject(obj: obj);
  }

  List<int> keyBytes() {
    return BytesUtils.fromHexString(comprossed);
  }

  List<int>? uncomprossedkeyBytes() {
    return BytesUtils.tryFromHexString(uncomprossed);
  }

  List<int>? chainCodeBytes() {
    return BytesUtils.tryFromHexString(chainCode);
  }
}

abstract class CryptoPrivateKeyData
    with CborSerializable
    implements CryptoKeyData {
  Bip32Base toBipKey();
  List<int> privateKeyBytes();
  abstract final String privateKey;
  abstract final String? extendedKey;
  abstract final CryptoPublicKeyData publicKey;
  abstract final CryptoCoins coin;
  factory CryptoPrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        cbor.tags, CryptoKeyConst.accessPrivateKeyResponse)) {
      return PrivateKeyData.fromCborBytesOrObject(obj: cbor);
    }
    return ADALegacyPrivateKeyData.fromCborBytesOrObject(obj: obj);
  }
}
