import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';

class IntegerBalance implements BalanceCore<BigInt> {
  factory IntegerBalance.zero(int currencyDecimal,
      {int? decimalPlaces, bool imutable = false, bool allowNegative = true}) {
    return IntegerBalance(BigInt.zero, currencyDecimal,
        imutable: imutable, allowNegative: allowNegative);
  }
  factory IntegerBalance(BigInt balance, int currencyDecimal,
      {int? decimalPlaces, bool imutable = false, bool allowNegative = true}) {
    final showDecimal =
        decimalPlaces ?? (currencyDecimal > 8 ? 8 : currencyDecimal);
    final currency =
        IntegerBalance._(currencyDecimal, showDecimal, imutable, allowNegative);
    currency._updateBalance(balance);
    return currency;
  }

  IntegerBalance._(this.currencyDecimal, this.showDecimal, this.imutable,
      this.allowNegative);

  IntegerBalance clone({bool? imutable, bool? allowNegative}) {
    return IntegerBalance(balance, currencyDecimal,
        imutable: imutable ?? this.imutable,
        allowNegative: allowNegative ?? this.allowNegative);
  }

  final bool allowNegative;
  BigInt _balance = BigInt.zero;
  @override
  BigInt get balance => _balance;

  late String _price;
  @override
  String get price => _price;

  final int currencyDecimal;
  late final int showDecimal;
  void _updateBalance(BigInt updateBalance) {
    if (!allowNegative && updateBalance.isNegative) {
      assert(false, "update balance should not be here.");
      return;
    }
    _price = PriceUtils.encodePrice(updateBalance, currencyDecimal,
        amoutDecimal: showDecimal);
    _balance = updateBalance;
    _viewPrice = StrUtils.to3Digits(_price, separator: ",");
    _isZero = _balance == BigInt.zero;
    _isNegative = _balance.isNegative;
    _largerThanZero = _balance > BigInt.zero;
  }

  @override
  bool updateBalance([BigInt? updateBalance]) {
    assert(!imutable, "Imutable balance");
    if (updateBalance == null || imutable) return false;
    if (updateBalance == _balance) return false;
    _updateBalance(updateBalance);
    return true;
  }

  BigInt _addAmount(BigInt amount) {
    return balance + amount;
  }

  BigInt _minusAmount(BigInt amount) {
    return balance - amount;
  }

  bool addAmount([BigInt? amount]) {
    assert(!imutable, "Imutable balance");
    if (amount == null || imutable) return false;
    final newBalance = _addAmount(amount);
    if (newBalance == _balance) return false;
    _updateBalance(newBalance);
    return true;
  }

  bool minusAmount([BigInt? amount]) {
    assert(!imutable, "Imutable balance");
    if (amount == null || imutable) return false;
    final newBalance = _minusAmount(amount);
    if (newBalance == _balance) return false;
    _updateBalance(newBalance);
    return true;
  }

  void zero() {
    if (imutable) return;
    _updateBalance(BigInt.zero);
  }

  bool _isZero = false;
  @override
  bool get isZero => _isZero;
  bool _isNegative = false;
  @override
  bool get isNegative => _isNegative;

  @override
  String toString() {
    return _price;
  }

  late String _viewPrice;

  @override
  String get viewPrice => _viewPrice;

  final bool imutable;
  bool _largerThanZero = false;
  @override
  bool get largerThanZero => _largerThanZero;

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
