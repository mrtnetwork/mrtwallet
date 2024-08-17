import 'dart:js_interop';

@JS("Action")
extension type Action._(JSObject _) {
  external factory Action();
  external JSPromise<JSAny?> openPopup(OpenPopupOptions? options);
}
@JS("OpenPopupOptions")
extension type OpenPopupOptions._(JSObject _) {
  external factory OpenPopupOptions({int? number, int? tabId});
  external int? get number;
  external int? get tabId;
}
