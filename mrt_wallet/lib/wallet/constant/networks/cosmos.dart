import 'package:blockchain_utils/blockchain_utils.dart';

class CosmosConst {
  static const String osmoHrp = "osmo";
  static const int accountNotFoundErrorCode = 22;
  static const int pathNotFoundErrorCode = 6;
  static const int defaultSlip44 = Slip44.atom;

  static final BigRational feeMultiplier = BigRational.parseDecimal("1.4");
  static final BigInt maxGasLimit = maxU64;
  static const String ibcChannelRegex = r'^channel-\d+$';
  static const String transferIbcPort = 'transfer';

  static String extractFactoryTokenName(String name) {
    if (name.startsWith("factory/")) return name.split("/").last;
    return name;
  }

  static const int maxTokenExponent = 18;
  static final BigRational avarageGasPrice = BigRational.parseDecimal("0.025");
  static final BigRational lowGasPrice = BigRational.parseDecimal("0.01");
  static final BigRational highGasPrice = BigRational.parseDecimal("0.04");
}
