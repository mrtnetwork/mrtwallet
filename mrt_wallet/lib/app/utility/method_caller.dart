import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/error/exception/app_exception.dart';
import 'package:mrt_wallet/provider/api/excepion/exception.dart';

class MethodCaller {
  static Future<void> wait({int milliseconds = 1000}) async {
    return await Future.delayed(Duration(milliseconds: milliseconds));
  }

  static Future<void> _callWithCanclable<T>(
    Future<T> Function() t,
    Canclable canclable,
  ) async {
    try {
      canclable.success(await t());
    } catch (e) {
      canclable.cancel(e);
    }
  }

  static Future<MethodResult<T>> call<T>(Future<T> Function() t,
      {Canclable? canclable, Duration? delay}) async {
    try {
      if (delay != null) {
        await Future.delayed(delay);
      }
      Future<T> r;
      if (canclable == null) {
        r = t();
      } else {
        Completer<T> completer = Completer<T>();
        canclable.setup(<T>() {
          return completer;
        });
        _callWithCanclable(t, canclable);

        r = completer.future;
      }
      return MethodResult.succsess(await r);
    } catch (e, stackTrace) {
      return MethodResult.error(e, stackTrace);
    }
  }
}

class MethodResult<T> {
  MethodResult.error(this.exception, this.trace) : _result = null;
  MethodResult.succsess(this._result)
      : exception = null,
        trace = null;
  final T? _result;
  String? get error {
    if (exception == null) return null;
    if (exception is AppException ||
        exception is BlockchainUtilsException ||
        exception is ApiProviderException) {
      return exception!.toString();
    }
    return "somthing_wrong";
  }

  final Object? exception;
  final StackTrace? trace;
  bool get hasError => error != null;
  bool get hasResult => error == null;
  bool get isCacel => exception is CancelableExption;
  T get result => _result!;
  bool get isBadCondition => exception is BadCondition;
}

typedef CompleterResult = Completer Function();

class Canclable<T> {
  CompleterResult? _setup;
  bool cancel([Object? exception]) {
    final completer = _setup?.call();
    if (completer?.isCompleted ?? true) return false;
    completer!.completeError(exception ?? const CancelableExption());
    _setup = null;
    return false;
  }

  void success(T result) {
    final completer = _setup?.call();
    if (completer?.isCompleted ?? true) return;
    completer!.complete(result);
    _setup = null;
  }

  void setup(CompleterResult setup) {
    assert(_setup == null, "please first complete or cancel");
    _setup = setup;
  }
}
