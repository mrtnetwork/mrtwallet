import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateFeeInfos {
  final IntegerBalance baseFee;
  final IntegerBalance lenFee;
  final IntegerBalance adjustedWeightFee;
  final IntegerBalance tip;
  final IntegerBalance total;
  final bool calculated;
  const SubstrateFeeInfos(
      {required this.baseFee,
      required this.lenFee,
      required this.adjustedWeightFee,
      required this.tip,
      required this.total,
      required this.calculated});
  factory SubstrateFeeInfos.zero(WalletPolkadotNetwork network) {
    return SubstrateFeeInfos(
        baseFee: IntegerBalance.zero(network.coinDecimal),
        lenFee: IntegerBalance.zero(network.coinDecimal),
        adjustedWeightFee: IntegerBalance.zero(network.coinDecimal),
        tip: IntegerBalance.zero(network.coinDecimal),
        total: IntegerBalance.zero(network.coinDecimal),
        calculated: false);
  }
  factory SubstrateFeeInfos.fromFeeDetails(
      {required QueryFeeInfoFrame fee,
      required WalletPolkadotNetwork network}) {
    if (fee.inclusionFee == null) return SubstrateFeeInfos.zero(network);
    final inclusionFee = fee.inclusionFee!;
    final BigRational totalFee = BigRational(inclusionFee.adjustedWeightFee +
        inclusionFee.baseFee +
        inclusionFee.lenFee +
        fee.tip);

    return SubstrateFeeInfos(
        baseFee: IntegerBalance(inclusionFee.baseFee, network.coinDecimal),
        lenFee: IntegerBalance(inclusionFee.lenFee, network.coinDecimal),
        adjustedWeightFee:
            IntegerBalance(inclusionFee.adjustedWeightFee, network.coinDecimal),
        tip: IntegerBalance(fee.tip, network.coinDecimal),
        total: IntegerBalance((totalFee * SubstrateConst.feeRate).toBigInt(),
            network.coinDecimal),
        calculated: true);
  }
}
