import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:on_chain/on_chain.dart';

enum ETHTransactionMode { transfer, erc20Transfer, contract, callContract }

abstract class EthereumTransactionForm implements TransactionForm {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError({IEthAddress? account});
  Map<String, dynamic> toEstimate(
      {required IEthAddress address,
      required WalletEthereumNetwork network,
      String? memo});
  ETHTransaction toTransaction(
      {required IEthAddress address,
      required WalletEthereumNetwork network,
      EthereumFee? fee,
      String? memo});
  ETHTransactionMode get mode;

  DynamicVoid? onStimateChanged;
}
