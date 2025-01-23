import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/models/transaction_output.dart';

abstract class CosmosTransactionForm extends TransactionForm {
  BigInt get callValue;
  @override
  String? validateError({ICosmosAddress? account});
  List<ServiceMessage> messages(CosmosBaseAddress signer);
  void setFeeToken(CosmosTransactionFeeInfo fee) {}
}
