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
  static const int minimumSolanaBase58SecretKey = 88;
  static const String mainnetGenesis =
      "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d";
  static const String testnetGenesis =
      "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY";
  static const String devnetGenesis =
      "EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG";
}
