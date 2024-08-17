enum WalletLockTime {
  twoMinute(120, "two_minute"),
  fiveMinute(300, "five_minute"),
  tenMinute(600, "ten_minute"),
  thirtyMinute(1800, "thirty_minute");

  final int value;
  final String viewName;
  const WalletLockTime(this.value, this.viewName);
  static WalletLockTime fromValue(int value) {
    if (value == 0) {
      return WalletLockTime.fiveMinute;
    }
    return values.firstWhere((element) => element.value == value,
        orElse: () => WalletLockTime.fiveMinute);
  }
}
