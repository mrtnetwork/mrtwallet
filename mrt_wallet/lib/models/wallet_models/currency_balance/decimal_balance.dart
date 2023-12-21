import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'core/balance_core.dart';

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
    return DecimalBalance._(
        rational, rational.toDecimal(digits: amoutDecimal), amoutDecimal);
  }

  DecimalBalance._(this._balance, this._price, this.showDecimal);
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
  }

  @override
  bool get isZero => _balance.isZero;
  @override
  bool get isNegative => _balance.isNegative;

  @override
  String toString() {
    return _price;
  }
}
