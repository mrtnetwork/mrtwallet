import 'dart:js_interop';

@JS("Object")
extension type MRTJsObject(JSObject _) implements JSObject {
  @JS("freeze")
  external static T freeze<T extends JSAny>(T obj);
  @JS("defineProperty")
  external static void defineProperty(
      JSObject obj, String prop, JSObject descriptor);
  @JS("isFrozen")
  external static bool isFrozen(JSObject obj);
  external static JSArray<JSString>? keys(JSAny? val);
  external static JSAny entries(JSAny? val);
  external bool hasOwnProperty(String nameOrSymbol);
  external static bool hasOwn(JSAny? obj, String prop);
  static List<String>? keys_(JSAny? val) {
    return MRTJsObject.keys(val)?.toDart.map((e) => e.toDart).toList();
  }

  static T? as<T extends JSAny>(
      {required JSAny? object, required List<String> keys}) {
    try {
      final properties = MRTJsObject.keys_(object);
      if (properties == null) return null;
      for (final i in keys) {
        if (!properties.contains(i)) return null;
      }
      return object as T;
    } catch (e) {
      return null;
    }
  }
}
