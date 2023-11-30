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
  T derive<T>(T derivator) {
    throw WalletExceptionConst.multiSigDerivationNotSuported;
  }

  @override
  List get variabels => [];
}
