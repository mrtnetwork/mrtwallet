import 'dart:js_interop';

@JS("Object")
extension type MRTJsObject(JSObject _) implements JSObject {
  @JS("freeze")
  external static T freeze<T extends JSObject>(T obj);
  @JS("defineProperty")
  external static void defineProperty(
      JSObject obj, String prop, JSObject descriptor);
  @JS("isFrozen")
  external static bool isFrozen(JSObject obj);
  external static JSAny keys(JSAny? val);
  external static JSAny entries(JSAny? val);
  external bool hasOwnProperty(String nameOrSymbol);
}
