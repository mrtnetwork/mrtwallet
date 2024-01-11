abstract class BalanceCore<T> {
  abstract final String price;
  abstract final String viewPrice;
  void updateBalance();
  bool get isZero;
  bool get isNegative;
  abstract final T balance;
}
