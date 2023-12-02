import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class WalletLogging {
  static print(dynamic message, {dynamic prefix, bool usePrint = false}) {
    if (!kDebugMode) {
      return;
    }
    const err = '\x1b[31m';
    const end = '\x1b[0m';
    const green = '\x1b[32m';
    final msg = '$green${prefix.toString()}$end =>  $err$message$end';
    dev.log(msg,
        time: DateTime.now(), zone: Zone.root, name: "wallet", level: 0);
  }
}
