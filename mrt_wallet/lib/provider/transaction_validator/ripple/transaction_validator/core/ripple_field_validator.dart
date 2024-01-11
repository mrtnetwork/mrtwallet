import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:xrp_dart/xrp_dart.dart';

abstract class RippleTransactionValidator implements TransactionValidator {
  XRPTransaction toTransaction(String account,
      {List<XRPLMemo> memos = const [],
      String signerPublicKey = "",
      BigInt? fee});

  XRPLTransactionType get transactionType;
  @override
  String? validateError({IXRPAddress? account});
}
