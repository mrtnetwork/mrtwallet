// ignore_for_file: avoid_print

class WalletLogging {
  static bool get isDebug => true;

  static void log(Object? text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void error(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void webview(String text) {
    print(text);
  }
}
