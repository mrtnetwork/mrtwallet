import 'package:mrt_native_support/web/mrt_native_web.dart';
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

extension QuickJS<T extends JSAny> on T {
  Proxy<T> toProxy({String? debugKey}) {
    final handler = ProxyMethodHandler(this, debugKey: debugKey);
    return Proxy<T>(handler.object, createJSInteropWrapper(handler));
  }

  T get freez => MRTJsObject.freeze(this);
}

extension QuickListOfString on JSArray<JSString> {
  List<String> get inDart => toDart.map((e) => e.toDart).toList();
}

extension QuickJSStringList on List<String> {
  JSArray<JSString> get toJS => map((e) => e.toJS).toList().toJS;
}
