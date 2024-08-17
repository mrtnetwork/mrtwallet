import 'package:mrt_wallet/app/utils/price/utils.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';

class IntegerBalance implements BalanceCore<BigInt> {
  factory IntegerBalance.zero(int currencyDecimal,
      {int? decimalPlaces, bool imutable = false}) {
    return IntegerBalance(BigInt.zero, currencyDecimal, imutable: imutable);
  }
  factory IntegerBalance(BigInt balance, int currencyDecimal,
      {int? decimalPlaces, bool imutable = false}) {
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final currency = IntegerBalance._(currencyDecimal, showDecimal, imutable);
    currency._updateBalance(balance);
    return currency;
  }

  IntegerBalance._(this.currencyDecimal, this.showDecimal, this.imutable);
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
    _viewPrice = StrUtils.to3Digits(_price, separator: ",");
  }

  @override
  void updateBalance([BigInt? updateBalance]) {
    assert(!imutable, "Imutable balance");
    if (updateBalance == null || imutable) return;
    _updateBalance(updateBalance);
  }

  void zero() {
    _updateBalance(BigInt.zero);
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

  @override
  bool get largerThanZero => _balance > BigInt.zero;

  IntegerBalance operator -(IntegerBalance other) {
    return IntegerBalance(_balance - other.balance, currencyDecimal);
  }

  IntegerBalance operator +(IntegerBalance other) {
    return IntegerBalance(_balance + other.balance, currencyDecimal);
  }

  bool operator <=(BigInt other) {
    return _balance <= other;
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (other is IntegerBalance &&
            other._balance == _balance &&
            other.currencyDecimal == currencyDecimal &&
            other.showDecimal == showDecimal);
  }

  @override
  int get hashCode =>
      _balance.hashCode ^ currencyDecimal.hashCode ^ showDecimal.hashCode;
}
