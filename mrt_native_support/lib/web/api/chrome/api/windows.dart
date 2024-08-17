import 'dart:js_interop';
import 'tabs.dart';

extension type ChromeWindows._(JSObject _) {
  external factory ChromeWindows();
  external JSPromise<ChromeWindow> create(ChromeWindowsCreateData? ccreateData);
  external JSPromise<ChromeWindow> getCurrent(
      ChromeWindowsQueryOptions? queryOptions);
  external JSPromise<ChromeWindow> get(
      int windowId, ChromeWindowsQueryOptions? queryOptions);
  external JSPromise<ChromeWindow> update(
      int windowId, ChromeWindowsUpdateInfo? updateInfo);
  Future<ChromeWindow> create_(
      {bool? focused,
      int? height,
      bool? incognito,
      int? left,
      // bool? setSelfAsOpener,
      int? tabId,
      int? top,
      String? url,
      int? width,
      String? type}) async {
    final future = create(ChromeWindowsCreateData(
            focused: focused,
            height: height,
            incognito: incognito,
            left: left,
            // setSelfAsOpener: setSelfAsOpener,
            tabId: tabId,
            top: top,
            type: type,
            url: url,
            width: width))
        .toDart;
    return await future;
  }

  Future<ChromeWindow> update_(int windowId,
      {bool? drawAttention,
      bool? focused,
      int? height,
      int? left,
      String? state,
      int? top,
      int? width}) async {
    final future = update(
            windowId,
            ChromeWindowsUpdateInfo(
                drawAttention: drawAttention,
                focused: focused,
                height: height,
                left: left,
                state: state,
                top: top,
                width: width))
        .toDart;
    return await future;
  }

  Future<ChromeWindow> get_(int windowId,
      {bool? populate, List<String>? windowTypes}) async {
    final future = get(
            windowId,
            ChromeWindowsQueryOptions(
                populate: populate,
                windowTypes: windowTypes?.map((e) => e.toJS).toList().toJS))
        .toDart;
    return await future;
  }

  Future<ChromeWindow> getCurrent_(
      {bool? populate, List<String>? windowTypes}) async {
    final future = getCurrent(ChromeWindowsQueryOptions(
            populate: populate,
            windowTypes: windowTypes?.map((e) => e.toJS).toList().toJS))
        .toDart;
    return await future;
  }
}

extension type ChromeWindowsCreateData._(JSObject _) implements JSAny {
  external factory ChromeWindowsCreateData(
      {bool? focused,
      int? height,
      bool? incognito,
      int? left,
      // bool? setSelfAsOpener,
      int? tabId,
      int? top,
      String? url,
      JSArray<JSString>? urls,
      int? width,
      String? type});
  external bool? get focused;
  external int? get height;
  external bool? get incognito;
  external int? get left;
  // external bool? get setSelfAsOpener;
  external int? get tabId;
  external int? get top;
  external String? get url;
  external String? get type;

  @JS("url")
  external JSArray<JSString>? get urls;
  external int? get width;
}
extension type ChromeWindow._(JSObject _) implements JSAny {
  external factory ChromeWindow();
  external bool? get alwaysOnTop;
  external bool? get focused;
  external int? get height;
  external int? get id;
  external bool get incognito;
  external int? get left;
  external int? get sessionId;
  external String? get state;
  external JSArray<ChromeTab>? get tabs;
  external int? get top;
  external String? type;
  external int? width;
}
extension type ChromeWindowsUpdateInfo._(JSObject _) implements JSAny {
  external factory ChromeWindowsUpdateInfo(
      {bool? drawAttention,
      bool? focused,
      int? height,
      int? left,
      String? state,
      int? top,
      int? width});
}
extension type ChromeWindowsQueryOptions._(JSObject _) implements JSAny {
  external factory ChromeWindowsQueryOptions(
      {bool? populate, JSArray<JSString>? windowTypes});
}
