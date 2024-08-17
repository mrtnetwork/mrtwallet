import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';

class DecimalBalance implements BalanceCore<BigRational> {
  factory DecimalBalance.zero({int amoutDecimal = 4}) {
    return DecimalBalance.fromRational(BigRational.zero,
        amoutDecimal: amoutDecimal);
  }
  factory DecimalBalance.fromString(String balance, {int amoutDecimal = 4}) {
    final inRetional = BigRational.tryParseDecimaal(balance);
    if (inRetional == null) {
      throw WalletExceptionConst.invalidBalance;
    }
    return DecimalBalance.fromRational(inRetional, amoutDecimal: amoutDecimal);
  }
  factory DecimalBalance.fromRational(BigRational rational,
      {int amoutDecimal = 4}) {
    final String toString = rational.toDecimal(digits: amoutDecimal);
    return DecimalBalance._(rational, rational.toDecimal(digits: amoutDecimal),
        amoutDecimal, StrUtils.to3Digits(toString, separator: ","));
  }

  DecimalBalance._(
      this._balance, this._price, this.showDecimal, this._viewPrice);
  BigRational _balance;
  @override
  BigRational get balance => _balance;

  late String _price;
  @override
  String get price => _price;
  late final int showDecimal;

  @override
  void updateBalance([BigRational? updateBalance]) {
    if (updateBalance == null) return;
    _balance = updateBalance;
    _price = _balance.toDecimal(digits: showDecimal);
    _viewPrice = StrUtils.to3Digits(_price, separator: ",");
  }

  @override
  bool get isZero => _balance.isZero;
  @override
  bool get isNegative => _balance.isNegative;

  @override
  String toString() {
    return _price;
  }

  String _viewPrice;

  @override
  String get viewPrice => _viewPrice;
  @override
  bool get largerThanZero => !_balance.isZero && !balance.isNegative;
}
