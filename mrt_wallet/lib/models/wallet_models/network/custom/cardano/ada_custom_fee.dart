import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:on_chain/ada/src/builder/builder/deposit.dart';

enum ADACustomFeeTypes {
  stakeRegistration("stake_registration");

  final String viewName;
  const ADACustomFeeTypes(this.viewName);
}

class ADATransactionDeposit {
  final ADACustomFeeTypes type;
  final NoneDecimalBalance fee;
  ADADepositBuilder toDepositBuilder() {
    return ADADepositBuilder(deposit: fee.balance);
  }

  const ADATransactionDeposit({required this.type, required this.fee});
  factory ADATransactionDeposit.amount(
      {required ADACustomFeeTypes type,
      required BigInt fee,
      APPCardanoNetwork? network}) {
    return ADATransactionDeposit(
        type: type,
        fee: NoneDecimalBalance(
            fee, network?.coinParam.decimal ?? CardanoUtils.decimal,
            imutable: true));
  }
}
