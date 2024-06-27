import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/keys/seed/seed.dart';

import 'package:mrt_wallet/wallet/models/coins/coins.dart';

class Bip32AddressIndex extends AddressDerivationIndex
    with Equatable, CborSerializable {
  final int? purpose;
  final int? coin;
  final int? accountLevel;
  final int? changeLevel;
  final int? addressIndex;
  final String? importedKeyId;
  final String? keyName;
  @override
  bool get isImportedKey => importedKeyId != null;
  @override
  final String? hdPath;

  @override
  final SeedTypes seedGeneration;
  @override
  final CryptoCoins currencyCoin;

  Bip32AddressIndex._({
    required this.purpose,
    required this.coin,
    required this.accountLevel,
    required this.changeLevel,
    required this.addressIndex,
    required this.currencyCoin,
    required this.seedGeneration,
    this.importedKeyId,
    this.keyName,
  }) : hdPath = _toPath(
            [purpose, coin, accountLevel, changeLevel, addressIndex],
            importedKeyId: importedKeyId);

  factory Bip32AddressIndex.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.accoutKeyIndex);
    final String? seedGeneration = cbor.elementAt(7);
    return Bip32AddressIndex._(
        accountLevel: cbor.elementAt(2),
        addressIndex: cbor.elementAt(4),
        changeLevel: cbor.elementAt(3),
        purpose: cbor.elementAt(0),
        coin: cbor.elementAt(1),
        currencyCoin: CustomCoins.getCoin(
            cbor.elementAt(6), CustomProposal.fromName(cbor.elementAt(5)))!,
        seedGeneration: seedGeneration == null
            ? SeedTypes.bip39
            : SeedTypes.fromName(seedGeneration),
        importedKeyId: cbor.elementAt(8),
        keyName: cbor.elementAt(9));
  }
  factory Bip32AddressIndex.byronLegacy(
      {required int firstIndex,
      required int secoundIndex,
      required CryptoCoins currencyCoin,
      String? keyName}) {
    return Bip32AddressIndex._(
        purpose: firstIndex,
        coin: secoundIndex,
        accountLevel: null,
        changeLevel: null,
        addressIndex: null,
        currencyCoin: currencyCoin,
        seedGeneration: SeedTypes.byronLegacySeed,
        keyName: keyName);
  }
  factory Bip32AddressIndex(
      {int? purpose,
      int? coin,
      int? accountLevel,
      int? changeLevel,
      int? addressIndex,
      required CryptoCoins currencyCoin,
      SeedTypes seedGeneration = SeedTypes.bip39,
      String? keyName}) {
    return Bip32AddressIndex._(
        purpose: purpose,
        coin: coin,
        accountLevel: accountLevel,
        changeLevel: changeLevel,
        addressIndex: addressIndex,
        currencyCoin: currencyCoin,
        seedGeneration: seedGeneration,
        keyName: keyName);
  }

  Bip32AddressIndex copyWith(
      {int? purpose,
      int? coin,
      int? accountLevel,
      int? changeLevel,
      int? addressIndex,
      String? path,
      SeedTypes? seedGeneration,
      CryptoCoins? currencyCoin,
      String? importedKeyId,
      String? keyName}) {
    return Bip32AddressIndex._(
        purpose: purpose ?? this.purpose,
        coin: coin ?? this.coin,
        accountLevel: accountLevel ?? this.accountLevel,
        changeLevel: changeLevel ?? this.changeLevel,
        addressIndex: addressIndex ?? this.addressIndex,
        seedGeneration: seedGeneration ?? this.seedGeneration,
        currencyCoin: currencyCoin ?? this.currencyCoin,
        importedKeyId: importedKeyId ?? this.importedKeyId,
        keyName: keyName ?? this.keyName);
  }

  factory Bip32AddressIndex.fromPath(
      {required String path,
      required CryptoCoins currencyCoin,
      required SeedTypes seedGeneration}) {
    final indexes = Bip32PathParser.parse(path).elems;
    if (indexes.length > 5) {
      throw WalletException("hd_wallet_path_max_indeqxes"
          .tr
          .replaceOne(BlockchainConst.maxBip32LevelIndex.toString()));
    }
    return Bip32AddressIndex(
        purpose: indexes.elementAtOrNull(0)?.index,
        coin: indexes.elementAtOrNull(1)?.index,
        accountLevel: indexes.elementAtOrNull(2)?.index,
        changeLevel: indexes.elementAtOrNull(3)?.index,
        addressIndex: indexes.elementAtOrNull(4)?.index,
        currencyCoin: currencyCoin,
        seedGeneration: seedGeneration,
        keyName: null);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          purpose,
          coin,
          accountLevel,
          changeLevel,
          addressIndex,
          CborStringValue(currencyCoin.proposal.specName),
          CborStringValue(currencyCoin.coinName),
          seedGeneration.name,
          importedKeyId,
          keyName
        ]),
        CborTagsConst.accoutKeyIndex);
  }

  @override
  List get variabels => [
        purpose,
        coin,
        accountLevel,
        changeLevel,
        addressIndex,
        currencyCoin.conf.type,
        seedGeneration.name,
        importedKeyId
      ];

  static String? _toPath(List<int?> indexses, {String? importedKeyId}) {
    if (indexses.isEmpty) return null;
    final bipIndexes = indexses
        .where((element) => element != null)
        .map((e) => Bip32KeyIndex(e!))
        .toList();
    if (bipIndexes.isEmpty) return null;
    String pathStr = "${Bip32PathConst.masterChar}/";
    for (final elem in bipIndexes) {
      if (!elem.isHardened) {
        pathStr += "${elem.toInt()}/";
      } else {
        pathStr += "${elem.unharden().toInt()}'/";
      }
    }
    return pathStr.substring(0, pathStr.length - 1);
  }

  Bip32Base _derive(Bip32Base key,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (maxLevel == Bip44Levels.master || indexes.isEmpty) return key;
    List<Bip32KeyIndex> bip32KeyIndexes = List.unmodifiable(indexes);
    final maxIndex = maxLevel.value;
    if (bip32KeyIndexes.length > maxIndex) {
      bip32KeyIndexes = List.unmodifiable(bip32KeyIndexes.sublist(0, maxIndex));
    }
    Bip32Base deriveToIndex = key;
    for (final i in bip32KeyIndexes) {
      deriveToIndex = deriveToIndex.childKey(i);
    }
    return deriveToIndex;
  }

  @override
  T derive<T extends Bip32Base>(T derivator,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    return _derive(derivator, maxLevel: maxLevel) as T;
  }

  List<Bip32KeyIndex> get indexes =>
      <int?>[purpose, coin, accountLevel, changeLevel, addressIndex]
          .where((element) => element != null)
          .map((e) => Bip32KeyIndex(e!))
          .toList();

  @override
  String toString() {
    if (importedKeyId != null) {
      return "imported_".tr.replaceOne(hdPath ?? "non_derivation".tr);
    }
    return hdPath ?? "non_derivation".tr;
  }

  @override
  AddressDerivationType get derivationType {
    return AddressDerivationType.bip32;
  }

  @override
  String get name => keyName ?? "main_key";
}
