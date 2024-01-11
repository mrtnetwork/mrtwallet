import 'package:mrt_wallet/models/wallet_models/account/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';

// enum TronTransactionMod { transfer, trc20Transfer }

abstract class TronTransactionValidator implements TransactionValidator {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError({ITronAddress? account});
  TransactionContractType get type;
  DynamicVoid? onStimateChanged;
  TronAddress? get destinationAccount;
  TronAddress? get smartContractAddress;
  Future<void> init(
      {required TVMApiProvider provider,
      required ITronAddress address,
      required NetworkAccountCore account});

  TronBaseContract toContract({required ITronAddress owner});
}
