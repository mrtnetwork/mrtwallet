import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/keys/access/private_key_response.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/derivation/core/derivation.dart';

class Bip32AddressIndex extends AddressDerivationIndex {
  final int? purpose;
  final int? coin;
  final int? accountLevel;
  final int? changeLevel;
  final int? addressIndex;
  @override
  final String? importedKeyId;
  final String? keyName;

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
        bytes, obj, CryptoKeyConst.accoutKeyIndex);
    return Bip32AddressIndex._(
        accountLevel: cbor.elementAt(2),
        addressIndex: cbor.elementAt(4),
        changeLevel: cbor.elementAt(3),
        purpose: cbor.elementAt(0),
        coin: cbor.elementAt(1),
        currencyCoin: CustomCoins.getCoin(
          name: cbor.elementAt(6),
          proposal: cbor.elementAt(5),
        ),
        seedGeneration: SeedTypes.fromName(cbor.elementAt(7)),
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
      required SeedTypes seedGeneration,
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
      throw WalletException("unsupported_hd_wallet_index");
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
        CryptoKeyConst.accoutKeyIndex);
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

  @override
  PrivateKeyData derive(PrivateKeyData masterKey,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (maxLevel == Bip44Levels.master || indexes.isEmpty) {
      return masterKey;
    }
    final key = masterKey.toBipKey();
    List<Bip32KeyIndex> bip32KeyIndexes = List.unmodifiable(indexes);
    final maxIndex = maxLevel.value;
    if (bip32KeyIndexes.length > maxIndex) {
      bip32KeyIndexes = List.unmodifiable(bip32KeyIndexes.sublist(0, maxIndex));
    }
    Bip32Base deriveToIndex = key;
    for (final i in bip32KeyIndexes) {
      deriveToIndex = deriveToIndex.childKey(i);
    }
    return PrivateKeyData.fromBip32(
        account: deriveToIndex,
        coin: masterKey.coin,
        keyName: masterKey.keyName);
  }

  List<Bip32KeyIndex> get indexes =>
      <int?>[purpose, coin, accountLevel, changeLevel, addressIndex]
          .where((element) => element != null)
          .map((e) => Bip32KeyIndex(e!))
          .toList();

  @override
  String toString() {
    return hdPath ?? "non_derivation";
  }

  @override
  AddressDerivationType get derivationType {
    return AddressDerivationType.bip32;
  }

  @override
  String get name => keyName ?? "main_key";

  @override
  AddressDerivationIndex asImportedKey(String importKeyId) {
    return copyWith(importedKeyId: importKeyId);
  }
}
