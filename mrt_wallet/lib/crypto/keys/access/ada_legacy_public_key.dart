import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';

class AdaLegacyPublicKeyData extends CryptoPublicKeyData {
  @override
  final String extendedKey;
  @override
  final String comprossed;
  @override
  final String? uncomprossed;
  final String hdPathKey;
  @override
  final String chainCode;
  @override
  final String keyName;
  const AdaLegacyPublicKeyData._(
      {required this.extendedKey,
      required this.comprossed,
      required this.uncomprossed,
      required this.keyName,
      required this.hdPathKey,
      required this.chainCode});
  factory AdaLegacyPublicKeyData.fromBip32(
      {required Bip32Base account,
      required List<int> hdPathKey,
      required String keyName}) {
    final comperesed = BytesUtils.toHexString(account.publicKey.compressed);
    final uncompresed = BytesUtils.toHexString(account.publicKey.uncompressed);
    return AdaLegacyPublicKeyData._(
        extendedKey: account.publicKey.toExtended,
        comprossed: comperesed,
        uncomprossed: uncompresed == comperesed ? null : uncompresed,
        keyName: keyName,
        chainCode: account.chainCode.toHex(),
        hdPathKey: BytesUtils.toHexString(hdPathKey));
  }
  factory AdaLegacyPublicKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessAdaPubliKeyResponse);
    return AdaLegacyPublicKeyData._(
        extendedKey: cbor.elementAt(0),
        comprossed: cbor.elementAt(1),
        uncomprossed: cbor.elementAt(2),
        keyName: cbor.elementAt(3),
        hdPathKey: cbor.elementAt(4),
        chainCode: cbor.elementAt(5));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          extendedKey,
          comprossed,
          uncomprossed ?? const CborNullValue(),
          keyName,
          hdPathKey,
          chainCode
        ]),
        CryptoKeyConst.accessAdaPubliKeyResponse);
  }

  List<int> hdPathKeyBytes() {
    return BytesUtils.fromHexString(hdPathKey);
  }

  @override
  List<int> chainCodeBytes() {
    return BytesUtils.fromHexString(chainCode);
  }
}
