import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/error/exception/app_exception.dart';
import 'package:mrt_wallet/provider/api/excepion/exception.dart';
import 'package:on_chain/on_chain.dart';
import 'package:xrp_dart/xrp_dart.dart';

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

  static Future<MethodResult<T>> retryCall<T>(
      Future<T> Function() t, bool Function(Object?) onExceptionRetry,
      {Canclable? canclable, Duration? delay, int retry = 3}) async {
    if (delay != null) {
      await Future.delayed(delay);
    }
    for (int i = 0; i < retry; i++) {
      final result = await call(t, canclable: canclable, delay: null);
      if (result.hasError) {
        if (result.isCancel) return result;
        if (i + 1 == retry) return result;
        if (onExceptionRetry(result.exception)) {
          continue;
        }
      }
      return result;
    }
    return call(t, canclable: canclable, delay: null);
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

  static T? nullOnException<T>(T? Function() t, {T? defaultValue}) {
    try {
      return t();
    } catch (e) {
      return defaultValue;
    }
  }
}

class MethodResult<T> {
  MethodResult.error(this.exception, this.trace);
  MethodResult.succsess(this._result)
      : exception = null,
        trace = null;
  late final T _result;
  String? get error {
    if (exception == null) return null;
    if (exception is AppException ||
        exception is BlockchainUtilsException ||
        exception is ApiProviderException ||
        exception is RPCException ||
        exception is RPCError ||
        exception is ArgumentError) {
      return exception!.toString();
    }

    return "somthing_wrong";
  }

  final Object? exception;
  final StackTrace? trace;
  bool get hasError => error != null;
  bool get hasResult => error == null;
  bool get isCancel => exception is CancelableExption;
  T get result => hasError ? throw WalletException(error!) : _result;
  bool get isBadCondition => exception is BadCondition;
  @override
  String toString() {
    if (hasError) {
      return "Error $error";
    }
    return "Success $result";
  }
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
