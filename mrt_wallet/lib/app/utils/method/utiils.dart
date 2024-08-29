import 'dart:async';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/utils.dart';
// import 'package:mrt_wallet/app/core.dart';
import 'package:http/http.dart' as http;
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/error/exception.dart';

typedef OnStreamReapose = void Function(
    int cumulativeBytesLoaded, int expectedTotalBytes);

class MethodUtils {
  static Future<void> wait({int milliseconds = 1000}) async {
    return await Future.delayed(Duration(milliseconds: milliseconds));
  }

  static T safeCast<T>(Object v, {String? onError}) {
    if (v is T) return v as T;
    throw WalletException.invalidArgruments(["$T", "${v.runtimeType}"]);
  }

  static Future<T> after<T>(Future<T> Function() t,
      {Duration milliseconds = Duration.zero}) async {
    return await Future.delayed(milliseconds, t);
  }

  static Future<MethodResult<T>> retryCall<T>(
      Future<T> Function() t, bool Function(Object?) onExceptionRetry,
      {Cancelable? canclable, Duration? delay, int retry = 3}) async {
    if (delay != null) {
      await Future.delayed(delay);
    }
    for (int i = 0; i < retry; i++) {
      final result = await call(t, cancelable: canclable, delay: null);
      if (result.hasError) {
        if (result.isCancel) return result;
        if (i + 1 == retry) return result;
        if (onExceptionRetry(result.exception)) {
          continue;
        }
      }
      return result;
    }
    return call(t, cancelable: canclable, delay: null);
  }

  static Future<MethodResult<T>> call<T>(Future<T> Function() t,
      {Cancelable? cancelable, Duration? delay, Duration? timeout}) async {
    try {
      if (delay != null) {
        await Future.delayed(delay);
      }
      Future<T> r;
      if (cancelable == null) {
        r = t();
      } else {
        Completer<T> completer = Completer<T>();
        cancelable.setup(<T>() {
          return completer;
        });
        cancelable.success(t);
        r = completer.future;
      }
      if (timeout != null) {
        r = r.timeout(timeout);
      }
      final result = await r;
      return MethodResult.success(result);
    } catch (e, stackTrace) {
      return MethodResult.error(e, stackTrace);
    }
  }

  static Future<MethodResult<T>> httpCaller<T>(
      Future<http.Response> Function() t,
      {Cancelable? cancelable,
      Duration? delay}) async {
    try {
      if (delay != null) {
        await Future.delayed(delay);
      }
      Future<http.Response> r;
      if (cancelable == null) {
        r = t();
      } else {
        Completer<http.Response> completer = Completer<http.Response>();
        cancelable.setup(<T>() {
          return completer;
        });
        cancelable.success(t);

        r = completer.future;
      }
      final response = await r;
      if (response.statusCode == 200) {
        if (T == String) return MethodResult.success(response.body as T);
        if (T == List<int>) {
          return MethodResult.success(response.bodyBytes as T);
        }
        final toJson = StringUtils.toJson(response.body);
        return MethodResult.success(toJson as T);
      }

      final errorJson =
          nullOnException(() => StringUtils.toJson(response.body));
      return MethodResult.error(
          ApiProviderException(
              statusCode: response.statusCode, message: errorJson?.toString()),
          null);
    } on http.ClientException catch (e, s) {
      return MethodResult.error(ApiProviderException(message: e.message), s);
    } on FormatException {
      return MethodResult.error(
          const ApiProviderException(message: "invalid_json_response"), null);
    } on TimeoutException catch (e, s) {
      return MethodResult.error(ApiProviderException(message: e.message), s);
    } catch (e, stackTrace) {
      return MethodResult.error(e, stackTrace);
    }
  }

  static Future<MethodResult<List<int>>> httpStreamCaller(
      Future<http.StreamedResponse> Function() t,
      {Cancelable? cancelable,
      Duration? delay,
      OnStreamReapose? onProgress}) async {
    StreamSubscription<List<int>>? subscription;
    try {
      if (delay != null) {
        await Future.delayed(delay);
      }
      Future<http.StreamedResponse> r;
      if (cancelable == null) {
        r = t();
      } else {
        Completer<http.StreamedResponse> completer =
            Completer<http.StreamedResponse>();
        cancelable.setup(<T>() {
          return completer;
        });
        cancelable.success(t);

        r = completer.future;
      }

      final response = await r;
      if (response.statusCode == 200) {
        Completer<List<int>> completer = Completer();
        if (cancelable != null) {
          cancelable.dispose();
          cancelable.setup(<T>() {
            return completer;
          });
        }
        List<int> data = List<int>.empty(growable: true);
        subscription = response.stream.listen((e) {
          data.addAll(e);
          if (response.contentLength != null) {
            onProgress?.call(data.length, response.contentLength!);
          }
        }, onDone: () {
          if (!completer.isCompleted) {
            completer.complete(data);
          }
        }, onError: (s) {
          completer.completeError(s);
        }, cancelOnError: true);
        final result = await completer.future;

        return MethodResult.success(result);
      }
      // throw ApiProviderException(code: response.statusCode);
      return MethodResult.error(
          ApiProviderException(code: response.statusCode), null);
    } on http.ClientException catch (e, s) {
      return MethodResult.error(ApiProviderException(message: e.message), s);
    } on FormatException {
      return MethodResult.error(
          const ApiProviderException(message: "invalid_json_response"), null);
    } on TimeoutException catch (e, s) {
      return MethodResult.error(ApiProviderException(message: e.message), s);
    } catch (e, stackTrace) {
      return MethodResult.error(e, stackTrace);
    } finally {
      subscription?.cancel();
      subscription = null;
    }
  }

  static Stream<T> prediocCaller<T>(Future<MethodResult<T>> Function() t,
      {Duration waitOnError = const Duration(seconds: 1),
      Duration waitOnSuccess = const Duration(seconds: 10),
      required Cancelable canclable,
      bool closeOnSuccess = false}) async* {
    bool run = true;
    while (run) {
      Completer<MethodResult<T>> completer = Completer();
      canclable.setup(() => completer);
      canclable.success(() => t());
      final result = await call(() async {
        final r = await completer.future;
        return r.result;
      });
      if (result.hasResult) {
        yield result.result;
        Completer<void> waitCompleter = Completer();
        canclable.setup(() => waitCompleter);
        final onErrorWait =
            await call(() async => waitCompleter.future.timeout(waitOnSuccess));
        if (onErrorWait.isCancel) {
          run = false;
          continue;
        }
        canclable.dispose();
      } else {
        if (result.isCancel) {
          run = false;
          continue;
        }
        Completer<void> waitCompleter = Completer();
        canclable.setup(() => waitCompleter);
        final onErrorWait =
            await call(() async => waitCompleter.future.timeout(waitOnError));
        if (onErrorWait.isCancel) {
          run = false;
          continue;
        }
        canclable.dispose();
      }
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
  factory MethodResult.success(T result) {
    return MethodResult._succsess(result);
  }
  factory MethodResult.error(Object exception, Object? trace) {
    final errorMessage = _errorMessage(exception);
    return MethodResult._error(
        error: errorMessage.$1,
        trace: trace,
        exception: exception,
        unknownError: errorMessage.$2);
  }
  MethodResult._error(
      {required Object this.exception,
      required this.error,
      this.trace,
      required this.unknownError});
  MethodResult._succsess(this._result)
      : exception = null,
        trace = null,
        error = null,
        unknownError = false;
  late final T _result;
  static (String, bool) _errorMessage(Object exception) {
    if (exception is AppException ||
        exception is BlockchainUtilsException ||
        exception is ApiProviderException ||
        exception is RPCError ||
        exception is ArgumentError) {
      return (exception.toString(), false);
    }
    return (exception.toString(), true);
  }

  final Object? exception;
  final Object? trace;
  final String? error;

  bool get hasError => exception != null;
  bool get hasResult => exception == null;
  bool get isCancel => exception is CancelableExption;
  final bool unknownError;
  T get result {
    if (hasError) {
      throw exception!;
    }
    return _result;
  }

  @override
  String toString() {
    if (hasError) {
      return "Error $error";
    }
    return "Success $result";
  }
}

typedef CompleterResult = Completer Function();

class Cancelable<T> {
  CompleterResult? _setup;
  bool cancel([Object? exception]) {
    final completer = _setup?.call();
    if (completer?.isCompleted ?? true) return false;
    completer!.completeError(exception ?? const CancelableExption());
    _setup = null;
    return false;
  }

  void success(FutureOr<T> Function() func) async {
    final completer = _setup?.call();
    if (completer?.isCompleted ?? true) return;
    var r = func();
    if (r is Future) {
      final result = await r;
      if (completer?.isCompleted ?? true) return;
      completer?.complete(result);
    } else {
      completer?.complete(r);
    }
    _setup = null;
  }

  void setup(CompleterResult setup) {
    assert(_setup == null, "please first complete or cancel");
    _setup = setup;
  }

  void dispose() {
    _setup = null;
  }
}

extension QuickFunction<T> on Function {
  T? nullOnException({List<dynamic>? positionalArguments}) =>
      MethodUtils.nullOnException(
          () => Function.apply(this, positionalArguments));

  T valueOrException(Object exception, {List<dynamic>? positionalArguments}) {
    final result = MethodUtils.nullOnException(
        () => Function.apply(this, positionalArguments));
    if (result == null) throw exception;
    return result as T;
  }
}
