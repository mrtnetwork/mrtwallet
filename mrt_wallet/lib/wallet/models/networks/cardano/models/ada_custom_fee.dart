import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/utils/cardano/cardano_utils.dart';
import 'package:on_chain/ada/src/builder/builder/deposit.dart';

enum ADACustomFeeTypes {
  stakeRegistration("stake_registration");

  final String viewName;
  const ADACustomFeeTypes(this.viewName);
}

class ADATransactionDeposit {
  final ADACustomFeeTypes type;
  final IntegerBalance fee;
  ADADepositBuilder toDepositBuilder() {
    return ADADepositBuilder(deposit: fee.balance);
  }

  const ADATransactionDeposit({required this.type, required this.fee});
  factory ADATransactionDeposit.amount(
      {required ADACustomFeeTypes type,
      required BigInt fee,
      WalletCardanoNetwork? network}) {
    return ADATransactionDeposit(
        type: type,
        fee: IntegerBalance(
            fee, network?.coinParam.decimal ?? CardanoUtils.decimal,
            imutable: true));
  }
}
