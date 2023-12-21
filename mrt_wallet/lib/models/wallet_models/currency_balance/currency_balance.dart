import 'package:mrt_wallet/app/utility/price/price_utils.dart';

import 'core/balance_core.dart';

class NoneDecimalBalance implements BalanceCore<BigInt> {
  factory NoneDecimalBalance.zero(int currencyDecimal, {int? decimalPlaces}) {
    return NoneDecimalBalance(BigInt.zero, currencyDecimal);
  }
  factory NoneDecimalBalance(BigInt balance, int currencyDecimal,
      {int? decimalPlaces}) {
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final price = PriceUtils.encodePrice(balance, currencyDecimal,
        amoutDecimal: showDecimal);
    return NoneDecimalBalance._(balance, price, currencyDecimal, showDecimal);
  }
  NoneDecimalBalance._(
      this._balance, this._price, this.currencyDecimal, this.showDecimal);
  BigInt _balance;
  @override
  BigInt get balance => _balance;

  late String _price;
  @override
  String get price => _price;

  final int currencyDecimal;
  late final int showDecimal;

  @override
  void updateBalance([BigInt? updateBalance]) {
    if (updateBalance == null) return;
    _price = PriceUtils.encodePrice(updateBalance, currencyDecimal,
        amoutDecimal: showDecimal);
    _balance = updateBalance;
  }

  @override
  bool get isZero => _balance == BigInt.zero;
  @override
  bool get isNegative => _balance < BigInt.zero;

  @override
  String toString() {
    return _price;
  }
}
