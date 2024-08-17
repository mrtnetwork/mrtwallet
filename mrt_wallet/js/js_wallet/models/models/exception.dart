import 'dart:js_interop';

import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';

@JS("Error")
extension type JSError._(JSAny _) implements JSAny {
  external factory JSError();
  external String? get message;
}

@JS("MRTWalletError")
extension type MRTWalletError._(JSAny _) implements JSError {
  external factory MRTWalletError(
      {required String message,
      required int code,
      required String walletCode,
      String? data,
      JSObject? request,
      String? requestId,
      String? stack});

  external String? get stack;
  external set stack(String? info);
  @JS("toString")
  external set toStr(JSFunction f);

  factory MRTWalletError.fromMessage(
      {required Web3ExceptionMessage message, String? stack}) {
    final json = message.toJson();
    json["stack"] ??= stack;
    final error = MRTWalletError._(json.jsify() ?? JSObject());
    String toString() {
      return message.message;
    }

    error.toStr = toString.toJS;
    return error;
  }
  factory MRTWalletError.fromJson(
      {required Map<String, dynamic> message, String? stack}) {
    message["stack"] ??= stack;
    final error = MRTWalletError._(message.jsify() ?? JSObject());
    String toString() {
      return message.toString();
    }

    error.toStr = toString.toJS;
    return error;
  }
}

extension ToWalletError on Web3ExceptionMessage {
  MRTWalletError toWalletError({String? stack}) {
    return MRTWalletError.fromMessage(message: this, stack: stack);
  }
}

extension WalletPromise<T extends JSAny?> on Future<T> {
  JSPromise<T> get toPromise {
    return JSPromise<T>((JSFunction resolve, JSFunction reject) {
      then((JSAny? value) {
        resolve.callAsFunction(resolve, value);
        return value;
      }, onError: (MRTWalletError error, StackTrace stackTrace) {
        error.stack = stackTrace.toString();
        reject.callAsFunction(reject, error);
        return error;
      }).catchError((e) {
        reject.callAsFunction(resolve, e);
        return e;
      });
    }.toJS);
  }
}
