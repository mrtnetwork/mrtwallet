import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';

class PublicKeyData extends CryptoPublicKeyData {
  @override
  final String? extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed;
  @override
  final String keyName;
  @override
  final String? chainCode;

  const PublicKeyData._(
      {required this.extendedKey,
      required this.comprossed,
      required this.uncomprossed,
      required this.keyName,
      required this.chainCode});
  factory PublicKeyData.fromBip32(
      {required Bip32Base account, required String keyName}) {
    final comperesed = BytesUtils.toHexString(account.publicKey.compressed);
    final uncompresed = BytesUtils.toHexString(account.publicKey.uncompressed);
    return PublicKeyData._(
        extendedKey: account.publicKey.toExtended,
        comprossed: comperesed,
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: account.publicKey.chainCode.toHex());
  }
  factory PublicKeyData(
      {required IPublicKey key,
      required CryptoCoins coin,
      required String keyName}) {
    final comperesed = BytesUtils.toHexString(key.compressed);
    final uncompresed = BytesUtils.toHexString(key.uncompressed);
    return PublicKeyData._(
        extendedKey: null,
        comprossed: key.toHex(),
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: null);
  }

  factory PublicKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessPubliKeyResponse);
    return PublicKeyData._(
        extendedKey: cbor.elementAt(0),
        comprossed: cbor.elementAt(1),
        uncomprossed: cbor.elementAt(2),
        keyName: cbor.elementAt(3),
        chainCode: cbor.elementAt(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          comprossed,
          uncomprossed ?? const CborNullValue(),
          keyName,
          chainCode
        ]),
        CryptoKeyConst.accessPubliKeyResponse);
  }
}
