import 'package:mrt_wallet/app/core.dart';
import 'core/balance_core.dart';

class NoneDecimalBalance implements BalanceCore<BigInt> {
  factory NoneDecimalBalance.zero(int currencyDecimal,
      {int? decimalPlaces, bool imutable = false}) {
    return NoneDecimalBalance(BigInt.zero, currencyDecimal, imutable: imutable);
  }
  factory NoneDecimalBalance(BigInt balance, int currencyDecimal,
      {int? decimalPlaces, bool imutable = false}) {
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final currency =
        NoneDecimalBalance._(currencyDecimal, showDecimal, imutable);
    currency._updateBalance(balance);
    return currency;
  }

  NoneDecimalBalance._(this.currencyDecimal, this.showDecimal, this.imutable);
  BigInt _balance = BigInt.zero;
  @override
  BigInt get balance => _balance;

  late String _price;
  @override
  String get price => _price;

  final int currencyDecimal;
  late final int showDecimal;
  void _updateBalance(BigInt updateBalance) {
    _price = PriceUtils.encodePrice(updateBalance, currencyDecimal,
        amoutDecimal: showDecimal);
    _balance = updateBalance;
    _viewPrice = _price.to3Digits;
  }

  @override
  void updateBalance([BigInt? updateBalance]) {
    assert(!imutable, "Imutable balance");
    if (updateBalance == null || imutable) return;
    _updateBalance(updateBalance);
  }

  @override
  bool get isZero => _balance == BigInt.zero;
  @override
  bool get isNegative => _balance < BigInt.zero;

  @override
  String toString() {
    return _price;
  }

  late String _viewPrice;

  @override
  String get viewPrice => _viewPrice;

  final bool imutable;
}
