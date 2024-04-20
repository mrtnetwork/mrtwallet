import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class MultiSigAddressIndex implements AddressDerivationIndex {
  const MultiSigAddressIndex();
  @override
  String get path => "multi_signature";

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([]),
        WalletModelCborTagsConst.multiSigAccountKeyIndex);
  }

  @override
  T derive<T>(T derivator, {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    throw WalletExceptionConst.multiSigDerivationNotSuported;
  }

  @override
  List get variabels => [];

  @override
  EllipticCurveTypes get curve =>
      throw WalletExceptionConst.inaccessibleKeyAlgorithm;

  @override
  CryptoCoins get currencyCoin =>
      throw WalletExceptionConst.inaccessibleKeyAlgorithm;

  @override
  String storageKey(
          {SeedGenerationType seedGenerationType = SeedGenerationType.bip39,
          Bip44Levels maxLevel = Bip44Levels.addressIndex}) =>
      throw WalletExceptionConst.unsuportedFeature;

  @override
  SeedGenerationType get seedGeneration =>
      throw WalletExceptionConst.unsuportedFeature;
}
