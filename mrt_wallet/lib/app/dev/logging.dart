class WalletLogging {
  static bool get isDebug => false;
  static debugPrint(dynamic message, {dynamic prefix, bool usePrint = false}) {}

  static void debug<T>(T? Function() t, {bool trace = false}) {
    try {
      t();
    } catch (e, s) {
      String message = "${e.runtimeType}: ${e.toString()}";
      if (trace) {
        message += "\n $s";
      }
      WalletLogging.debugPrint(message, prefix: "DEBUG-");
    }
  }
}
