import 'dart:js_interop';

import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';

@JS("Error")
extension type JSError._(JSAny _) implements JSAny {
  external factory JSError();
  external String? get message;
}

@JS("JSWalletError")
extension type JSWalletError._(JSAny _) implements JSError {
  external factory JSWalletError(
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

  factory JSWalletError.fromMessage(
      {required Web3ExceptionMessage message, String? stack}) {
    final json = message.toJson();
    json["stack"] ??= stack;
    final error = JSWalletError._(json.jsify() ?? JSObject());
    String toString() {
      return "MRT: ${message.message}";
    }

    error.toStr = toString.toJS;
    return error;
  }
  factory JSWalletError.fromJson(
      {required Map<String, dynamic> message, String? stack}) {
    message["stack"] ??= stack;
    final error = JSWalletError._(message.jsify() ?? JSObject());
    String toString() {
      return message.toString();
    }

    error.toStr = toString.toJS;
    return error;
  }
}

extension ToWalletError on Web3ExceptionMessage {
  JSWalletError toWalletError({String? stack}) {
    return JSWalletError.fromMessage(message: this, stack: stack);
  }
}
