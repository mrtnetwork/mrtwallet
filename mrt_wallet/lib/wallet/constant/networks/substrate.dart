import 'package:blockchain_utils/utils/utils.dart';

class SubstrateConst {
  static const List<int> supportedVersion = [14, 15];
  static final BigRational feeRate = BigRational.parseDecimal("1.1");
  static const String balancePalletName = "Balances";
  static const String utilityBatchVariantName = "batch";
  static const String utilityPalletName = "Utility";
  static const String systemPalletName = "System";
  static const String systemRemarkVariantName = "remark";
}
