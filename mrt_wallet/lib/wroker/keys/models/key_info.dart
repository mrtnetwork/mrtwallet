import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wroker/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';

class Bip32KeyInfo with CborSerializable {
  final String extendedKey;
  final CryptoCoins coin;
  const Bip32KeyInfo({required this.extendedKey, required this.coin});
  factory Bip32KeyInfo.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CryptoKeyConst.bip32KeyInfo);
    final CryptoProposal proposal = CustomProposal.fromName(cbor.elementAt(1));
    final CryptoCoins coin = CustomCoins.getCoin(cbor.elementAt(2), proposal)!;
    return Bip32KeyInfo(extendedKey: cbor.elementAt(0), coin: coin);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [extendedKey, coin.proposal.specName, coin.coinName]),
        CryptoKeyConst.bip32KeyInfo);
  }

  Bip32Base toKey() {
    return BlockchainUtils.extendedKeyToBip32(
        extendedKey: extendedKey, coin: coin);
  }
}
