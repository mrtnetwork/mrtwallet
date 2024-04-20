abstract class BalanceCore<T> {
  abstract final String price;
  abstract final String viewPrice;
  void updateBalance();
  bool get isZero;
  bool get isNegative;
  bool get largerThanZero;
  abstract final T balance;
}
