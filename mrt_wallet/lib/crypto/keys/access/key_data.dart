import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_private_key.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/monero_private_key.dart';
import 'package:mrt_wallet/crypto/keys/access/monero_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/access/public_key_response.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';

import 'view_keys.dart';
// import 'package:mrt_wallet/wroker/worker.dart';

enum CryptoPublicKeyDataType {
  public(CryptoKeyConst.accessPubliKeyResponse),
  ada(CryptoKeyConst.accessAdaPubliKeyResponse),
  monero(CryptoKeyConst.accessMoneroPublicKeyResponse);

  final List<int> tag;
  const CryptoPublicKeyDataType(this.tag);
  static CryptoPublicKeyDataType fromTag(List<int>? tag) {
    return CryptoPublicKeyDataType.values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

enum CryptoPrivateKeyDataType {
  public(CryptoKeyConst.accessPrivateKeyResponse),
  ada(CryptoKeyConst.accessAdaLegacyPrivateKeyResponse),
  monero(CryptoKeyConst.accessMoneroPrivateKeyResponse);

  final List<int> tag;
  const CryptoPrivateKeyDataType(this.tag);
  static CryptoPrivateKeyDataType fromTag(List<int>? tag) {
    return CryptoPrivateKeyDataType.values.firstWhere(
        (e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

abstract class CryptoKeyData with CborSerializable {
  abstract final String keyName;
}

abstract class CryptoPublicKeyData
    with CborSerializable
    implements CryptoKeyData {
  const CryptoPublicKeyData();
  abstract final CryptoPublicKeyDataType type;
  abstract final String? extendedKey;
  abstract final String comprossed;
  abstract final String? chainCode;
  abstract final String? uncomprossed;

  PublicKeysView get toViewKey => PublicKeysView(
      extendKey: extendedKey,
      comprossed: comprossed,
      uncomprossed: uncomprossed,
      chainCode: chainCode,
      keyName: keyName,
      keyType: type);

  factory CryptoPublicKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = CryptoPublicKeyDataType.fromTag(cbor.tags);
    switch (type) {
      case CryptoPublicKeyDataType.public:
        return PublicKeyData.fromCborBytesOrObject(obj: cbor);
      case CryptoPublicKeyDataType.ada:
        return AdaLegacyPublicKeyData.fromCborBytesOrObject(obj: cbor);
      case CryptoPublicKeyDataType.monero:
        return MoneroPublicKeyData.deserialize(obj: cbor);
    }
  }

  List<int> keyBytes({PubKeyModes mode = PubKeyModes.compressed}) {
    switch (mode) {
      case PubKeyModes.compressed:
        return BytesUtils.fromHexString(comprossed);
      case PubKeyModes.uncompressed:
        assert(uncomprossed != null, "should not use uncomprossed mode.");
        return BytesUtils.fromHexString(uncomprossed ?? comprossed);
    }
  }

  List<int>? uncomprossedkeyBytes() {
    return BytesUtils.tryFromHexString(uncomprossed);
  }

  List<int>? chainCodeBytes() {
    return BytesUtils.tryFromHexString(chainCode);
  }

  T cast<T extends CryptoPublicKeyData>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

abstract class CryptoPrivateKeyData
    with CborSerializable
    implements CryptoKeyData {
  abstract final CryptoPrivateKeyDataType type;
  const CryptoPrivateKeyData();
  Bip32Base toBipKey();
  List<int> privateKeyBytes();
  abstract final String privateKey;
  abstract final String? extendedKey;
  abstract final CryptoPublicKeyData publicKey;
  abstract final CryptoCoins coin;
  abstract final String? wif;
  PrivateKeysView get toViewKey => PrivateKeysView(
      extendKey: extendedKey,
      privateKey: privateKey,
      wif: wif,
      curve: coin.conf.type,
      keyName: keyName,
      keyType: type,
      inNetworkStyle: null);
  factory CryptoPrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, object: obj);
    final type = CryptoPrivateKeyDataType.fromTag(cbor.tags);
    switch (type) {
      case CryptoPrivateKeyDataType.public:
        return PrivateKeyData.fromCborBytesOrObject(obj: cbor);
      case CryptoPrivateKeyDataType.ada:
        return ADALegacyPrivateKeyData.fromCborBytesOrObject(obj: cbor);
      case CryptoPrivateKeyDataType.monero:
        return MoneroPrivateKeyData.deserialize(obj: cbor);
    }
  }
  factory CryptoPrivateKeyData.fromSeed(
      {required CryptoCoins coin,
      required String keyName,
      required List<int> seedBytes}) {
    if (coin is BipCoins) {
      final account =
          BlockchainUtils.seedToBipKey(seedBytes: seedBytes, coin: coin);
      return CryptoPrivateKeyData.fromBip32(
          account: account, coin: coin, keyName: keyName);
    }
    final substrate = BlockchainUtils.seedToSubstratePrivateKey(
        seedBytes: seedBytes, coin: coin);
    return PrivateKeyData(coin: coin, keyName: keyName, key: substrate);
  }
  factory CryptoPrivateKeyData.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    switch (coin) {
      case Bip44Coins.moneroEd25519Slip:
        return MoneroPrivateKeyData.fromBip32(
            account: account, coin: coin, keyName: keyName);
      default:
        return PrivateKeyData.fromBip32(
            coin: coin, keyName: keyName, account: account);
    }
  }
  T cast<T extends CryptoPrivateKeyData>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}
