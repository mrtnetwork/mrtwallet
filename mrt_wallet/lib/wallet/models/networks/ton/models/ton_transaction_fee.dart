import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:ton_dart/ton_dart.dart';

class TonTransactionFeeDetails {
  final IntegerBalance storageFee;
  final IntegerBalance gasFee;
  final IntegerBalance actionPhase;
  final IntegerBalance fee;
  final IntegerBalance totalFee;
  final bool isEstimated;
  final List<TonEmulatedMessage> internalMessages;
  bool get hasInternalFee => internalMessages.isNotEmpty;
  final bool success;
  final String? resultDescription;
  TonTransactionFeeDetails._(
      {required this.storageFee,
      required this.gasFee,
      required this.actionPhase,
      required this.fee,
      required this.isEstimated,
      required this.totalFee,
      this.resultDescription,
      required this.success,
      List<TonEmulatedMessage>? internalMessages})
      : internalMessages =
            List<TonEmulatedMessage>.unmodifiable(internalMessages ?? []);

  factory TonTransactionFeeDetails(
      {required BigInt actionPhase,
      required BigInt storageFee,
      required BigInt gasFee,
      List<TonEmulatedMessage> internalMessages = const [],
      String? resultDescription,
      required bool success,
      bool isEstimated = true}) {
    final IntegerBalance actionPhaseP = IntegerBalance(
        actionPhase, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance storageFeeP = IntegerBalance(
        storageFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance gasFeeP = IntegerBalance(gasFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance fee = IntegerBalance(
        actionPhase + storageFee + gasFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final internalFess = internalMessages.fold(BigInt.zero,
        (previousValue, element) => previousValue + element.total.balance);
    final IntegerBalance totalFees = IntegerBalance(
        internalFess + fee.balance, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);

    return TonTransactionFeeDetails._(
        storageFee: storageFeeP,
        gasFee: gasFeeP,
        fee: fee,
        isEstimated: isEstimated,
        actionPhase: actionPhaseP,
        internalMessages: internalMessages,
        success: success,
        resultDescription: resultDescription,
        totalFee: totalFees);
  }
  factory TonTransactionFeeDetails.nonEstimate() {
    return TonTransactionFeeDetails(
        actionPhase: BigInt.zero,
        storageFee: BigInt.zero,
        gasFee: BigInt.zero,
        isEstimated: false,
        success: true);
  }
}

class TonEmulatedMessage {
  final bool success;
  final IntegerBalance storageFee;
  final IntegerBalance gasFee;
  final IntegerBalance actionPhase;
  final IntegerBalance total;
  final TonAddress? destination;
  final String? resultDescription;

  const TonEmulatedMessage._(
      {required this.storageFee,
      required this.gasFee,
      required this.actionPhase,
      required this.total,
      required this.success,
      this.resultDescription,
      this.destination});

  factory TonEmulatedMessage(
      {required BigInt actionPhase,
      required BigInt storageFee,
      required BigInt gasFee,
      required bool success,
      TonAddress? destination,
      String? resultDescription}) {
    final IntegerBalance actionPhaseP = IntegerBalance(
        actionPhase, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance storageFeeP = IntegerBalance(
        storageFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance gasFeeP = IntegerBalance(gasFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    final IntegerBalance totalFee = IntegerBalance(
        actionPhase + storageFee + gasFee, TonConst.deciaml,
        imutable: true, decimalPlaces: 2);
    return TonEmulatedMessage._(
        storageFee: storageFeeP,
        gasFee: gasFeeP,
        total: totalFee,
        actionPhase: actionPhaseP,
        success: success,
        destination: destination,
        resultDescription: resultDescription);
  }
}
