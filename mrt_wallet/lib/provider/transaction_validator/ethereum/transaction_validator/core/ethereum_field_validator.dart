import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/on_chain.dart';

enum ETHTransactionMode { transfer, erc20Transfer, contract, callContract }

abstract class EthereumTransactionValidator implements TransactionValidator {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError({IEthAddress? account});
  Map<String, dynamic> toEstimate(
      {required IEthAddress address,
      required APPEVMNetwork network,
      String? memo});
  ETHTransaction toTransaction(
      {required IEthAddress address,
      required APPEVMNetwork network,
      EthereumFee? fee,
      String? memo});
  ETHTransactionMode get mode;

  DynamicVoid? onStimateChanged;
}
