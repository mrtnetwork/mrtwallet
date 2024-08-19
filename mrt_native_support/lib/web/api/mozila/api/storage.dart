import 'dart:js_interop';

import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("localStorage")
external LocalStorage get localStorage;

@JS("localStorage")
extension type LocalStorage._(JSObject _) implements JSAny {
  external factory LocalStorage();

  @JS("getItem")
  external String? getItem(String key);

  @JS("setItem")
  external void setItem(String keyName, String keyValue);

  @JS("removeItem")
  external void removeItem(String keyName);

  /// An integer representing the number of the key you want to get the name of. This is a zero-based index.
  @JS("key")
  external String? key(int index);

  @JS("clear")
  external void clear();

  Map<String, String> getAll() {
    final toDart = MRTJsObject.entries(localStorage).dartify() as List;
    return Map<String, String>.fromEntries(toDart.map((e) {
      try {
        final str = List<String>.from(e);
        return MapEntry<String, String>(str[0], str[1]);
      } catch (e) {
        return null;
      }
    }).whereType<MapEntry<String, String>>());
  }

  Map<String, String> getItems(List<String> keys) {
    final items = getAll();
    return Map<String, String>.fromEntries(
        items.entries.where((e) => keys.contains(e.key)));
  }

  void removeItems(List<String> keys) {
    for (final i in keys) {
      removeItem(i);
    }
  }
}
