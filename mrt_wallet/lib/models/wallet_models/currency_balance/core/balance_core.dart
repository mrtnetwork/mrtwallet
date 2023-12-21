abstract class BalanceCore<T> {
  abstract final String price;
  void updateBalance();
  bool get isZero;
  bool get isNegative;
  abstract final T balance;
}
