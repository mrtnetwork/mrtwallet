import 'dart:js_interop';

extension type JSEvent<H extends Function?>._(JSObject _) {
  @JS("addListener")
  external void addListener(JSFunction? callback);

  @JS("removeListener")
  external void removeListener(JSFunction? callback);
}
