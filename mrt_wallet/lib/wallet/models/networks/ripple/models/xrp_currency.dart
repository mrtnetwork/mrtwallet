import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XRPCurrencyAmount {
  const XRPCurrencyAmount(
      {required this.amount, required this.price, required this.token});

  final CurrencyAmount amount;
  final BalanceCore price;
  final Token token;
}
