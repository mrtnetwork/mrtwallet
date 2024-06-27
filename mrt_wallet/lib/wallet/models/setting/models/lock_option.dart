enum WalletLockTime {
  never(0, "never"),
  oneMinute(60, "one_minute"),
  twoMinute(120, "two_minute"),
  fiveMinute(300, "five_minute");

  final int value;
  final String viewName;
  const WalletLockTime(this.value, this.viewName);
  static WalletLockTime fromValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}
