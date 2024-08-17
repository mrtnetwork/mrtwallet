import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';

abstract class TronTransactionForm implements TransactionForm {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError({ITronAddress? account});
  TransactionContractType get type;
  DynamicVoid? onStimateChanged;
  TronAddress? get destinationAccount;
  TronAddress? get smartContractAddress;
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account});

  TronBaseContract toContract({required ITronAddress owner});
}
