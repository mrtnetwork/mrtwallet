import 'package:cosmos_sdk/cosmos_sdk.dart';

class CosmosUtils {
  static const int accountNotFoundErrorCode = 22;
  static final Coin gasPrice = Coin(denom: "uatom", amount: BigInt.from(10000));
  static Fee simulateFee({String? denom, BigInt? gasLimit, BigInt? amount}) =>
      Fee(
        gasLimit: gasLimit ?? BigInt.from(300000),
        amount: [
          Coin(denom: denom ?? "uatom", amount: amount ?? BigInt.from(10000)),
        ],
      );
  static const double feeMultiplier = 1.4;
  static Fee calculateFee(
      {required int gasUsed, double multiplier = 1.4, required String denom}) {
    final gp = (gasUsed * multiplier).ceil();
    return Fee(amount: [
      gasPrice.copyWith(amount: BigInt.from((gp * 0.1).ceil()), denom: denom),
    ], gasLimit: BigInt.from(gp));
  }
}
