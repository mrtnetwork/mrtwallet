import 'package:blockchain_utils/utils/utils.dart';

class APPSubstrateConst {
  static const List<int> supportedVersion = [14, 15, 16];
  static final BigRational feeRate = BigRational.parseDecimal("1.1");
  static const String balancePalletName = "Balances";
  static const String utilityBatchVariantName = "batch";
  static const String utilityPalletName = "Utility";
  static const String systemPalletName = "System";
  static const String systemRemarkVariantName = "remark";
  static const int defaultEraPeriod = 155;
  static const int maxDecimals = 38;
}
