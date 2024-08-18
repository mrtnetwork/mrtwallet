import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/ada_legacy_public_key.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
// import 'package:mrt_wallet/wroker/utils/global/utils.dart';

class ADALegacyPrivateKeyData implements CryptoPrivateKeyData {
  @override
  final CryptoCoins coin;
  @override
  final String privateKey;
  @override
  final String extendedKey;
  final String? wif;
  @override
  final String keyName;

  @override
  final CryptoPublicKeyData publicKey;
  factory ADALegacyPrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessAdaLegacyPrivateKeyResponse);
    final CryptoCoins coin = CustomCoins.getCoin(
      name: cbor.elementAt(1),
      proposal: cbor.elementAt(0),
    );
    return ADALegacyPrivateKeyData._(
        privateKey: cbor.elementAt(2),
        extendedKey: cbor.elementAt(3),
        coin: coin,
        wif: cbor.elementAt(4),
        keyName: cbor.elementAt(5),
        publicKey: AdaLegacyPublicKeyData.fromCborBytesOrObject(
            obj: cbor.getCborTag(6)));
  }

  const ADALegacyPrivateKeyData._(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName,
      required this.publicKey});
  factory ADALegacyPrivateKeyData.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName,
      required List<int> hdPathKey}) {
    final wifKey =
        BlockchainUtils.toWif(privateKey: account.privateKey.raw, coin: coin);

    return ADALegacyPrivateKeyData._(
      privateKey: account.privateKey.toHex(),
      extendedKey: account.privateKey.toExtended,
      coin: coin,
      wif: wifKey,
      keyName: keyName,
      publicKey: AdaLegacyPublicKeyData.fromBip32(
          account: account, hdPathKey: hdPathKey, keyName: keyName),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          coin.proposal.specName,
          coin.coinName,
          privateKey,
          extendedKey,
          wif ?? const CborNullValue(),
          keyName,
          publicKey.toCbor()
        ]),
        CryptoKeyConst.accessAdaLegacyPrivateKeyResponse);
  }

  @override
  Bip32Base toBipKey() {
    return BlockchainUtils.extendedKeyToBip32Key(
        extendedKey: extendedKey, coin: coin);
  }

  @override
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }
}
