import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class ByronLegacyAddressIndex extends AddressDerivationIndex
    with Equatable, CborSerializable {
  final int firstIndex;
  final int secondIndex;

  factory ByronLegacyAddressIndex.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.byronLegacyKeyIndex);
      final int firstIndex = cbor.elementAt(0);
      final int secondIndex = cbor.elementAt(1);
      final String proposal = cbor.elementAt(2);
      final String coinName = cbor.elementAt(3);
      final CryptoCoins? coin =
          CryptoCoins.getCoin(coinName, CryptoProposal.fromName(proposal));
      return ByronLegacyAddressIndex._(
          firstIndex: firstIndex, secondIndex: secondIndex, currencyCoin: coin);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  ByronLegacyAddressIndex._(
      {required this.firstIndex,
      required this.secondIndex,
      required this.currencyCoin})
      : curve = null;
  ByronLegacyAddressIndex(
      {required this.firstIndex,
      required this.secondIndex,
      required this.currencyCoin})
      : curve = null;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          CborIntValue(firstIndex),
          CborIntValue(secondIndex),
          CborStringValue(currencyCoin!.proposal.specName),
          CborStringValue(currencyCoin!.coinName),
        ]),
        WalletModelCborTagsConst.byronLegacyKeyIndex);
  }

  @override
  List get variabels =>
      [firstIndex, secondIndex, currencyCoin?.conf.type ?? curve];

  @override
  String get path {
    return 'm/$firstIndex\'/$secondIndex\'';
  }

  @override
  String toString() {
    return path;
  }

  @override
  T derive<T>(T derivator, {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (derivator is! Bip32Base) {
      throw WalletException.invalidArgruments(
          ["Bip32Base", derivator.runtimeType.toString()]);
    }
    return derivator.derivePath(path) as T;
  }

  @override
  final CryptoCoins? currencyCoin;

  @override
  final EllipticCurveTypes? curve;
  @override
  String storageKey({Bip44Levels maxLevel = Bip44Levels.addressIndex}) =>
      BytesUtils.toHexString(MD5.hash([
        ...toCbor().encode(),
        ...seedGeneration.name.codeUnits,
        ...maxLevel.name.codeUnits
      ]));

  @override
  SeedGenerationType get seedGeneration => SeedGenerationType.byronLegacySeed;
}
