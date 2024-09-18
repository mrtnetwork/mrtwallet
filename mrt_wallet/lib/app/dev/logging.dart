// ignore_for_file: avoid_print

class WalletLogging {
  static bool get isDebug => true;

  static void log(String text) {
    print('\x1B[31m$text\x1B[0m');
    // print(text);
  }

  static void warning(String text) {
    // print('\x1B[33m$text\x1B[0m');
    print(text);
  }

  static void webview(String text) {
    // print('\x1B[32m$text\x1B[0m');
    print(text);
  }
}

///printWarning
