import 'package:mrt_wallet/app/utility/price/price_utils.dart';

class CurrencyBalance {
  factory CurrencyBalance.zero(int currencyDecimal, {int? decimalPlaces}) {
    return CurrencyBalance(BigInt.zero, currencyDecimal);
  }
  factory CurrencyBalance(BigInt balance, int currencyDecimal,
      {int? decimalPlaces}) {
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final price = PriceUtils.encodePrice(balance, currencyDecimal,
        amoutDecimal: showDecimal);
    return CurrencyBalance._(balance, price, currencyDecimal, showDecimal);
  }
  CurrencyBalance._(
      this._balance, this._price, this.currencyDecimal, this.showDecimal);
  BigInt _balance;
  BigInt get balance => _balance;

  late String _price;
  String get price => _price;

  final int currencyDecimal;
  late final int showDecimal;

  void updateBalance(BigInt updateBalance) {
    _price = PriceUtils.encodePrice(updateBalance, currencyDecimal,
        amoutDecimal: showDecimal);
    _balance = updateBalance;
  }

  bool get isZero => _balance == BigInt.zero;
  bool get isNegative => _balance <= BigInt.zero;

  @override
  String toString() {
    return _price;
  }
}
