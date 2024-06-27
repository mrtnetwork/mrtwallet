import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/utils/price/utils.dart';

class SolanaConst {
  static const int memoLength = (566 * 2) - 1;
  static const int systemProgramAccountSpace = 129;
  static final BigInt systemProgramRent = BigInt.from(890880);
  static final String systemProgramRentSol = PriceUtils.encodePrice(
      systemProgramRent, decimal,
      amoutDecimal: APPConst.defaultDecimalPlaces);
  static const int decimal = 9;
  static final BigRational maximumAccountSizeBytes = BigRational.from(10240);
  static final BigRational maxSPLTokenDecimalPlaces = BigRational.from(18);
}
