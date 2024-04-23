import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleTransactionValidator implements TransactionValidator {
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee});
  String get helperUri;
  XRPLTransactionType get transactionType;
  @override
  String? validateError({IXRPAddress? account});
  String get validatorName;
  String get validatorDescription;
  void removeIndex<T>(ValidatorField<List<T>> field, int index);
  void setListValue<T>(ValidatorField<List<T>> field, T? value);
}
