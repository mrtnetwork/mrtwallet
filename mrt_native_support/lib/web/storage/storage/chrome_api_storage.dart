// import 'dart:async';
// import 'dart:js_interop';
// import 'package:mrt_native_support/web/api/chrome/chrome.dart';
// import 'package:mrt_native_support/web/api/chrome/models/models.dart';

// class ChromeAPIStorage {
//   final StorageArea storage;
//   const ChromeAPIStorage(this.storage);

//   Future<bool> setStorage(String key, String value) async {
//     final Completer<bool> completer = Completer();
//     void onCallBack() {
//       final lastError = extention.runtime.lastError;
//       completer.complete(lastError == null);
//     }

//     storage.setStorage({key: value}.jsify(), onCallBack.toJS);
//     return await completer.future;
//   }

//   Future<String?> getStorage(String key) async {
//     final Completer<String> completer = Completer<String>();
//     void onCallBack(JSObject obj) {
//       final data = obj.dartify() as Map;
//       completer.complete(data[key]);
//     }

//     storage.getStorage(key, onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   Map<String, String> getMultipledata(JSObject obj) {
//     final jsMap = obj.dartify() as Map;
//     final Map<String, String> data = {};
//     for (final i in jsMap.entries) {
//       if (i.key is String && i.value is String) {
//         data[i.key] = i.value;
//       }
//     }
//     return data;
//   }

//   Future<Map<String, String>> getAllStorage() async {
//     final Completer<Map<String, String>> completer = Completer();
//     void onCallBack(JSObject obj) {
//       completer.complete(getMultipledata(obj));
//     }

//     storage.getStorage(null, onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   Future<Map<String, String>> getMultipleKey(List<String> keys) async {
//     final Completer<Map<String, String>> completer = Completer();
//     void onCallBack(JSObject obj) {
//       completer.complete(getMultipledata(obj));
//     }

//     storage.getMultipleStorage(
//         keys.map((e) => e.toJS).toList().toJS, onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   Future<bool> removeKey(String key) async {
//     final Completer<bool> completer = Completer();
//     void onCallBack() {
//       final lastError = extention.runtime.lastError;
//       completer.complete(lastError == null);
//     }

//     storage.remove(key, onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   Future<bool> removeMultipleKeys(List<String> keys) async {
//     final Completer<bool> completer = Completer();
//     void onCallBack() {
//       final lastError = extention.runtime.lastError;
//       completer.complete(lastError == null);
//     }

//     storage.removeMultiple(
//         keys.map((e) => e.toJS).toList().toJS, onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   Future<bool> removeAll() async {
//     final Completer<bool> completer = Completer();
//     void onCallBack() {
//       final lastError = extention.runtime.lastError;
//       completer.complete(lastError == null);
//     }

//     storage.clear(onCallBack.toJS);
//     final result = await completer.future;
//     return result;
//   }

//   ExtentionEvents<StorageEventListener> get onChageStorage {
//     final controller = StreamController<StorageEventListener>();
//     final listener = (JSObject obj) {
//       final mapData = obj.dartify() as Map;

//       final data = mapData
//           .map((k, v) => MapEntry(k as String, Map<String, String>.from(v)));
//       for (final i in data.entries) {
//         controller.add(StorageEventListener(i.key,
//             newValue: i.value["newValue"], oldValue: i.value["oldValue"]));
//       }
//     }.toJS;
//     storage.onChanged.addListener(listener);
//     controller.onCancel = () {
//       storage.onChanged.removeListener(listener);
//     };
//     return ExtentionEvents(
//         stream: controller.stream,
//         listener: listener,
//         event: storage.onChanged);
//   }
// }
