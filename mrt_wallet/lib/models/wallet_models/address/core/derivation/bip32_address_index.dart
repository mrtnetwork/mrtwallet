import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class Bip32AddressIndex extends AddressDerivationIndex
    with Equatable, CborSerializable {
  final int purpose;
  final int coin;
  final int accountLevel;
  final int changeLevel;
  final int addressIndex;

  @override
  final String path;

  @override
  final EllipticCurveTypes? curve;
  @override
  final SeedGenerationType seedGeneration;
  @override
  final CryptoCoins? currencyCoin;

  const Bip32AddressIndex._(
      {required this.purpose,
      required this.coin,
      required this.accountLevel,
      required this.changeLevel,
      required this.addressIndex,
      required this.curve,
      required this.currencyCoin,
      required this.seedGeneration,
      required this.path});

  factory Bip32AddressIndex.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.accoutKeyIndex);
      final int purposeLevel = cbor.value[0].value;
      final int coinLevel = cbor.value[1].value;
      final int accountLevel = cbor.value[2].value;
      final int changeLevel = cbor.value[3].value;
      final int addressIndex = cbor.value[4].value;
      final String? curve = cbor.elementAt(5);
      final String? proposal = cbor.elementAt(6);
      final String? coinName = cbor.elementAt(7);
      final CryptoCoins? coin = proposal != null && coinName != null
          ? CryptoCoins.getCoin(coinName, CryptoProposal.fromName(proposal))
          : null;
      final String? seedGeneration = cbor.elementAt(8);
      return Bip32AddressIndex._(
          accountLevel: accountLevel,
          addressIndex: addressIndex,
          changeLevel: changeLevel,
          purpose: purposeLevel,
          coin: coinLevel,
          path: _toPath([
            purposeLevel,
            coinLevel,
            accountLevel,
            changeLevel,
            addressIndex
          ]),
          curve: curve == null
              ? coin == null
                  ? EllipticCurveTypes.secp256k1
                  : null
              : EllipticCurveTypes.fromName(curve),
          currencyCoin: coin,
          seedGeneration: seedGeneration == null
              ? SeedGenerationType.bip39
              : SeedGenerationType.fromName(seedGeneration));
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }

  factory Bip32AddressIndex(
      {required int purpose,
      required int coin,
      required int accountLevel,
      required int changeLevel,
      required int addressIndex,
      required CryptoCoins currencyCoin,
      required SeedGenerationType seedGeneration}) {
    return Bip32AddressIndex._(
        purpose: purpose,
        coin: coin,
        path: _toPath([purpose, coin, accountLevel, changeLevel, addressIndex]),
        curve: null,
        accountLevel: accountLevel,
        changeLevel: changeLevel,
        addressIndex: addressIndex,
        currencyCoin: currencyCoin,
        seedGeneration: seedGeneration);
  }

  factory Bip32AddressIndex.fromBip44KeyIndexDetais(
      {required List<Bip44LevelsDetails> indexes,
      required CryptoCoins currencyCoin,
      required SeedGenerationType seedGeneration}) {
    final int purpose = indexes
        .firstWhere((element) => element.level == Bip44Levels.purpose)
        .index;
    final int coin = indexes
        .firstWhere((element) => element.level == Bip44Levels.coin)
        .index;
    final int accountLevel = indexes
        .firstWhere((element) => element.level == Bip44Levels.account)
        .index;
    final int changeLevel = indexes
        .firstWhere((element) => element.level == Bip44Levels.change)
        .index;
    final int addressIndex = indexes
        .firstWhere((element) => element.level == Bip44Levels.addressIndex)
        .index;
    return Bip32AddressIndex(
        purpose: purpose,
        coin: coin,
        accountLevel: accountLevel,
        changeLevel: changeLevel,
        addressIndex: addressIndex,
        currencyCoin: currencyCoin,
        seedGeneration: seedGeneration);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          CborIntValue(purpose),
          CborIntValue(coin),
          CborIntValue(accountLevel),
          CborIntValue(changeLevel),
          CborIntValue(addressIndex),
          if (curve == null)
            const CborNullValue()
          else
            CborStringValue(curve!.name),
          if (currencyCoin != null) ...[
            CborStringValue(currencyCoin!.proposal.specName),
            CborStringValue(currencyCoin!.coinName),
          ] else ...[
            const CborNullValue(),
            const CborNullValue()
          ],
          seedGeneration.name
        ]),
        WalletModelCborTagsConst.accoutKeyIndex);
  }

  @override
  List get variabels => [
        purpose,
        coin,
        accountLevel,
        changeLevel,
        addressIndex,
        currencyCoin?.conf.type ?? curve,
        seedGeneration.name
      ];

  static String _toPath(List<int> indexses) {
    String path = "m/";
    for (final i in indexses) {
      final toBip32KeyIndex = Bip32KeyIndex(i);
      if (toBip32KeyIndex.isHardened) {
        path += "${toBip32KeyIndex.unharden().index}'/";
      } else {
        path += "${toBip32KeyIndex.index}/";
      }
    }
    path = path.substring(0, path.length - 1);
    return path;
  }

  @override
  T derive<T extends Bip32Base>(T derivator,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    Bip32Base deriveToIndex = derivator;
    for (int i = 0; i < maxLevel.value; i++) {
      deriveToIndex = deriveToIndex.childKey(indexes.elementAt(i));
    }
    return deriveToIndex as T;
  }

  List<Bip32KeyIndex> get indexes => [
        Bip32KeyIndex(purpose),
        Bip32KeyIndex(coin),
        Bip32KeyIndex(accountLevel),
        Bip32KeyIndex(changeLevel),
        Bip32KeyIndex(addressIndex)
      ];

  @override
  String storageKey({Bip44Levels maxLevel = Bip44Levels.addressIndex}) =>
      BytesUtils.toHexString(MD5.hash([
        ...toCbor().encode(),
        ...seedGeneration.name.codeUnits,
        ...maxLevel.name.codeUnits
      ]));

  @override
  String toString() {
    return path;
  }
}
