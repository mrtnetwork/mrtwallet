import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';
import 'package:mrt_wallet/wroker/keys/models/seed.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';

class MultiSigAddressIndex extends AddressDerivationIndex {
  @override
  final String? hdPath = null;
  final String? keyName;
  const MultiSigAddressIndex({this.keyName});

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([keyName]),
        CryptoKeyConst.multiSigAccountKeyIndex);
  }

  @override
  T derive<T extends Bip32Base>(T derivator,
      {Bip44Levels maxLevel = Bip44Levels.addressIndex}) {
    throw WalletExceptionConst.multiSigDerivationNotSuported;
  }

  @override
  List get variabels => [];

  @override
  CryptoCoins get currencyCoin =>
      throw WalletExceptionConst.inaccessibleKeyAlgorithm;

  @override
  SeedTypes get seedGeneration => throw WalletExceptionConst.unsuportedFeature;

  @override
  AddressDerivationType get derivationType => AddressDerivationType.multisig;

  @override
  String get name => "multi_signature";

  @override
  String toString() {
    return name;
  }

  @override
  String? get importedKeyId => null;
}
