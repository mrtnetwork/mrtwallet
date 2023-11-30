import 'dart:async';

import 'package:flutter/foundation.dart' as foundation;

class AppCompute {
  static Future<R> compute<M, R>(FutureOr<R> Function(M) callback, M message) {
    return foundation.compute(callback, message);
  }
}
