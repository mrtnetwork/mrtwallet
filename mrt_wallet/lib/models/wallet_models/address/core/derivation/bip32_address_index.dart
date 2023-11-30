import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
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

      return Bip32AddressIndex(
          accountLevel: accountLevel,
          addressIndex: addressIndex,
          changeLevel: changeLevel,
          purpose: purposeLevel,
          coin: coinLevel);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  Bip32AddressIndex(
      {required this.purpose,
      required this.coin,
      required this.accountLevel,
      required this.changeLevel,
      required this.addressIndex});
  factory Bip32AddressIndex.fromBip44KeyIndexDetais(
      List<Bip44LevelsDetails> indexes) {
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
        addressIndex: addressIndex);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          CborIntValue(purpose),
          CborIntValue(coin),
          CborIntValue(accountLevel),
          CborIntValue(changeLevel),
          CborIntValue(addressIndex)
        ]),
        WalletModelCborTagsConst.accoutKeyIndex);
  }

  @override
  List get variabels =>
      [purpose, coin, accountLevel, changeLevel, addressIndex];

  String? _cachedPath;

  @override
  String get path {
    _cachedPath ??= _toPath(variabels.cast());
    return _cachedPath!;
  }

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
  String toString() {
    return path;
  }

  @override
  T derive<T>(T derivator) {
    if (derivator is! Bip32Base) {
      throw WalletException.invalidArgruments(
          ["Bip32Slip10Secp256k1", derivator.runtimeType.toString()]);
    }
    final deriveToIndex = derivator
        .childKey(Bip32KeyIndex(purpose))
        .childKey(Bip32KeyIndex(coin))
        .childKey(Bip32KeyIndex(accountLevel))
        .childKey(Bip32KeyIndex(changeLevel))
        .childKey(Bip32KeyIndex(addressIndex));
    return deriveToIndex as T;
  }
}
