import 'dart:js_interop';

import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';

@JS("Error")
extension type JSError._(JSAny _) implements JSAny {
  external factory JSError({String? message});
  external String? get message;
}

extension type JSWalletError._(JSAny _) implements JSError {
  external factory JSWalletError({String? message});
  external String? get stack;
  external set stack(String? info);
  @JS("toString")
  external set toStr(JSFunction f);

  factory JSWalletError.fromMessage(
      {required Web3ExceptionMessage message, String? stack}) {
    Map<String, dynamic> json = message.toJson();
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
    Map<String, dynamic> errorJson = Map<String, dynamic>.from(message);
    errorJson["stack"] ??= stack;
    errorJson.removeWhere((k, v) => v == null);
    final error = JSWalletError._(errorJson.jsify() ?? JSObject());
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
