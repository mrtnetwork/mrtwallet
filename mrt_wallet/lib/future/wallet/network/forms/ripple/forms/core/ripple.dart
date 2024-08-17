import 'package:mrt_wallet/wallet/models/chain/address/networks/xrp/addresses/xrp.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

abstract class RippleTransactionForm implements TransactionForm {
  List<TransactionFormField> get fields;
  XRPTransaction toTransaction(XRPAddress account,
      {List<XRPLMemo> memos = const [], XRPLSignature? signer, BigInt? fee});
  String get helperUri;
  XRPLTransactionType get transactionType;
  @override
  String? validateError({IXRPAddress? account});
  String get validatorName;
  String get validatorDescription;
  void removeIndex<T>(TransactionFormField<List<T>> field, int index);
  void setListValue<T>(TransactionFormField<List<T>> field, T? value);
  void setValue<T>(TransactionFormField<T>? field, T? value);
}
