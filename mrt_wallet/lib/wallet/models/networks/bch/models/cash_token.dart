import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class BCHCashToken {
  BCHCashToken({required this.cashToken});
  final CashToken cashToken;
  late final Token token =
      Token(name: cashToken.category, symbol: cashToken.category, decimal: 0);
  late final IntegerBalance balance =
      IntegerBalance(cashToken.amount, 0, imutable: true);
}
