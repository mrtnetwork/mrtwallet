import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';

class BCHCashToken {
  BCHCashToken({required this.cashToken});
  final CashToken cashToken;
  late final Token token =
      Token(name: cashToken.category, symbol: cashToken.category, decimal: 0);
  late final NoneDecimalBalance balance =
      NoneDecimalBalance(cashToken.amount, 0, imutable: true);
}
