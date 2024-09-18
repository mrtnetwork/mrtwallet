import '../../models/models.dart';
import 'dart:js_interop';

extension WalletPromise<T extends JSAny?> on Future<T> {
  JSPromise<T> get toPromise {
    return JSPromise<T>((JSFunction resolve, JSFunction reject) {
      then((JSAny? value) {
        resolve.callAsFunction(resolve, value);
        return value;
      }, onError: (JSWalletError error, StackTrace stackTrace) {
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

extension QuickJS on JSAny {
  external bool hasOwnProperty(String prop);
}
