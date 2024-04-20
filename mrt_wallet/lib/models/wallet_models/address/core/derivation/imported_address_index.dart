import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class ImportedAddressIndex with Equatable implements AddressDerivationIndex {
  const ImportedAddressIndex({required this.accountId, this.bip32KeyIndex});
  factory ImportedAddressIndex.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.importedAccountKeyIndex);
      Bip32AddressIndex? keyIndex;

      if (cbor.value[0] is! CborNullValue) {
        keyIndex = Bip32AddressIndex.fromCborBytesOrObject(obj: cbor.value[0]);
      }
      final String accountId = cbor.value[1].value;
      return ImportedAddressIndex(
          accountId: accountId, bip32KeyIndex: keyIndex);
    } catch (e) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
  }
  final String accountId;
  final AddressDerivationIndex? bip32KeyIndex;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          bip32KeyIndex == null
              ? const CborNullValue()
              : bip32KeyIndex!.toCbor(),
          accountId
        ]),
        WalletModelCborTagsConst.importedAccountKeyIndex);
  }

  @override
  String get path =>
      "imported${bip32KeyIndex == null ? '' : ' ( ${bip32KeyIndex!.path} )'}";

  @override
  List get variabels => [accountId, bip32KeyIndex];

  @override
  T derive<T>(T derivator, {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    if (derivator is! Bip32Base) {
      throw WalletException.invalidArgruments(
          ["Bip32Base", derivator.runtimeType.toString()]);
    }
    if (bip32KeyIndex != null) {
      return bip32KeyIndex!.derive(derivator);
    }

    return derivator;
  }

  @override
  EllipticCurveTypes get curve => throw UnimplementedError();

  @override
  CryptoCoins get currencyCoin => throw UnimplementedError();

  @override
  String storageKey({Bip44Levels maxLevel = Bip44Levels.addressIndex}) =>
      BytesUtils.toHexString(MD5.hash([
        ...toCbor().encode(),
        ...seedGeneration.name.codeUnits,
        ...maxLevel.name.codeUnits
      ]));

  @override
  SeedGenerationType get seedGeneration =>
      bip32KeyIndex?.seedGeneration ?? SeedGenerationType.none;
}
