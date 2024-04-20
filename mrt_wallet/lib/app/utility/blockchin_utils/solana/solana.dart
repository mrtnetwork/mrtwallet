import 'package:mrt_wallet/models/wallet_models/currency_balance/currency_balance.dart';

class SolanaConstants {
  static const int memoLength = (566 * 2) - 1;
  static const int systemProgramAccountSpace = 129;
  static final NoneDecimalBalance systemProgramRent =
      NoneDecimalBalance(BigInt.from(890880), decimal, imutable: true);
  static const int decimal = 9;
}
