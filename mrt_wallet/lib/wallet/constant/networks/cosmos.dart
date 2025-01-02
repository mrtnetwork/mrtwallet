import 'package:blockchain_utils/blockchain_utils.dart';

class CosmosConst {
  static const String osmoHrp = "osmo";
  static const int accountNotFoundErrorCode = 22;
  static const int defaultSlip44 = Slip44.atom;
  static const int pathNotFoundErrorCode = 6;
  static final BigRational defaultGasPrice = BigRational.parseDecimal("0.025");
  static final BigRational feeMultiplier = BigRational.parseDecimal("1.4");
  static final BigInt maxGasLimit = maxU64;

  static String extractFactoryTokenName(String name) {
    if (name.startsWith("factory/")) return name.split("/").last;
    return name;
  }

  static const int maxTokenExponent = 18;
}
