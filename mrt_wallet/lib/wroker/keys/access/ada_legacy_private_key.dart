import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/bip/wif/wif.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/keys/access/key_data.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';

class ADALegacyPrivateKeyData implements CryptoPrivateKeyData {
  final CryptoCoins coin;
  @override
  final String privateKey;
  @override
  final String extendedKey;
  final String? wif;
  @override
  final String keyName;
  factory ADALegacyPrivateKeyData.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.accessAdaLegacyPrivateKeyResponse);
    final CryptoProposal proposal = CustomProposal.fromName(cbor.elementAt(0));
    final CryptoCoins coin = CustomCoins.getCoin(cbor.elementAt(1), proposal)!;
    return ADALegacyPrivateKeyData._(
        privateKey: cbor.elementAt(2),
        extendedKey: cbor.elementAt(3),
        coin: coin,
        wif: cbor.elementAt(4),
        keyName: cbor.elementAt(5));
  }

  const ADALegacyPrivateKeyData._(
      {required this.privateKey,
      required this.extendedKey,
      required this.coin,
      required this.wif,
      required this.keyName});
  factory ADALegacyPrivateKeyData.fromBip32(
      {required Bip32Base account,
      required CryptoCoins coin,
      required String keyName}) {
    final wifKey = coin.conf.wifNetVer != null
        ? WifEncoder.encode(account.privateKey.raw,
            netVer: coin.conf.wifNetVer!)
        : null;

    return ADALegacyPrivateKeyData._(
        privateKey: account.privateKey.toHex(),
        extendedKey: account.privateKey.toExtended,
        coin: coin,
        wif: wifKey,
        keyName: keyName);
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
          keyName
        ]),
        CryptoKeyConst.accessAdaLegacyPrivateKeyResponse);
  }

  @override
  Bip32Base toKey() {
    return BlockchainUtils.extendedKeyToBip32(
        extendedKey: extendedKey, coin: coin);
  }
}
