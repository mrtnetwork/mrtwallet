import 'dart:js_interop';

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
    return Map<String, String>.from(localStorage as Map);
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
