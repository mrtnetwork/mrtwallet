import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/web/api/chrome/models/models/storage.dart';
import 'events.dart' show JSEvent;

extension type Storage._(JSObject _) {
  external final String? message;
  @JS("local")
  external StorageArea local;
  @JS("session")
  external StorageArea session;
  @JS("sync")
  external StorageArea sync;
}

extension type StorageArea._(JSObject _) {
  @JS("onChanged")
  external JSEvent onChanged;

  @JS("get")
  external void getStorage(String? key, JSFunction callBack);

  @JS("get")
  external JSPromise<JSObject> getStorageAsync(String? key);

  @JS("get")
  external void getMultipleStorage(JSArray<JSString> keys, JSFunction callBack);

  @JS("get")
  external JSPromise<JSObject> getMultipleStorageAsync(JSArray<JSString> keys);

  @JS("remove")
  external void remove(String key, JSFunction? callBack);

  @JS("remove")
  external JSPromise removeAsync(String key);

  @JS("remove")
  external void removeMultiple(JSArray<JSString> keys, JSFunction? callBack);

  @JS("remove")
  external JSPromise removeMultipleAsync(JSArray<JSString> key);

  @JS("clear")
  external void clear(JSFunction? callBack);

  @JS("clear")
  external JSPromise clearAsync();

  @JS("set")
  external void setStorage(JSAny? object, JSFunction callBack);

  @JS("set")
  external JSPromise setStorageAsync(JSAny? object);

  Future<String?> getStorage_(String key) async {
    final future = getStorageAsync(key).toDart;
    final result = (await future).dartify() as Map;
    if (result[key] is String) {
      return result[key];
    }
    return null;
  }

  Future<void> setStorage_(String key, String value) async {
    final future = setStorageAsync({key: value}.jsify()).toDart;
    await future;
  }

  Future<void> setMultipleStorage_(Map<String, String> data) async {
    final future = setStorageAsync(data.jsify()).toDart;
    await future;
  }

  Future<void> remove_(String key) async {
    final future = removeAsync(key).toDart;
    await future;
  }

  Future<void> clear_() async {
    final future = clearAsync().toDart;
    await future;
  }

  Future<void> removeMultiple_(List<String> keys) async {
    final future =
        removeMultipleAsync(keys.map((e) => e.toJS).toList().toJS).toDart;
    await future;
  }

  Map<String, String> _parseItems(JSObject object) {
    final result = object.dartify() as Map;
    final Map<String, String> data = {};
    for (final i in result.entries) {
      if (i.key is String && i.value is String) {
        data[i.key] = i.value;
      }
    }
    return data;
  }

  Future<Map<String, String>> getMultipleStorage_(List<String> keys) async {
    final future =
        getMultipleStorageAsync(keys.map((e) => e.toJS).toList().toJS).toDart;
    final result = await future;
    return _parseItems(result);
  }

  Future<Map<String, String>> getAll_() async {
    final future = getStorageAsync(null).toDart;
    final result = await future;

    return _parseItems(result);
  }

  Stream<StorageEventListener> get onChageStorage {
    final controller = StreamController<StorageEventListener>();
    final listener = (JSObject obj) {
      final mapData = obj.dartify() as Map;
      final data = mapData
          .map((k, v) => MapEntry(k as String, Map<String, String>.from(v)));
      for (final i in data.entries) {
        controller.add(StorageEventListener(i.key,
            newValue: i.value["newValue"], oldValue: i.value["oldValue"]));
      }
    }.toJS;
    onChanged.addListener(listener);
    controller.onCancel = () {
      onChanged.removeListener(listener);
    };
    return controller.stream;
  }
}
