part of 'package:mrt_native_support/io/io_platforms.dart';

class _WebViewConst {
  static const String onPageStart = "OnPageStart";
  static const String onPageError = "onPageError";
  static const String onPageFinished = "onPageFinished";
  static const String onPageProgress = "onPageProgress";
  static const String openPage = "openPage";
  static const String webView = "webView";
  static const String injectJavaScript = "injectJavaScript";
  static const String canGoForward = "canGoForward";
  static const String canGoBack = "canGoBack";
  static const String goBack = "goBack";
  static const String goForward = "goForward";
  static const String updateFrame = "updateFrame";
  static const String dispose = "dispose";
  static const String reload = "reload";
  static const String request = "request";
  static const String createWebView = "createWebView";
  static const String addInterface = "addJsInterface";
  static const String removeInterface = "removeInterface";
}

class WebViewIoInterface implements PlatformWebView {
  final Map<String?, WebViewListener> _listeners = {};

  Future<void> _methodCallHandler(Map<String, dynamic> args) async {
    if (args['type'] == "log") {
      print('console: \x1B[33m${args['data']}\x1B[0m');
      return;
    }
    if (args["eventName"] == null) return;
    final event = WebViewEvent.fromJson(args);

    _emitListener(_listeners[null], event);
    _emitListener(_listeners[event.viewId], event);
  }

  void _emitListener(WebViewListener? listener, WebViewEvent event) {
    if (listener == null) return;
    switch (event.eventName) {
      case _WebViewConst.onPageStart:
        listener.onPageStart(event);
        break;
      case _WebViewConst.onPageError:
        listener.onPageError(event);
        break;
      case _WebViewConst.onPageFinished:
        listener.onPageFinished(event);
        break;
      case _WebViewConst.onPageProgress:
        listener.onPageProgress(event);
        break;
      case _WebViewConst.request:
        listener.onPageRequest(event);
        break;
      default:
    }
  }

  Future<T> _call<T>({
    required String type,
    required String viewType,
    Map<String, dynamic> args = const {},
  }) async {
    final result =
        await IoPlatformInterface._channel.invokeMethod(_WebViewConst.webView, {
      "type": type,
      "id": viewType,
      ...args,
    });
    return result;
  }

  @override
  Future<Object?> loadScript(
      {required String viewType, required String script}) {
    return _call(
        type: _WebViewConst.injectJavaScript,
        viewType: viewType,
        args: {"script": script});
  }

  @override
  Future<void> openUrl({required String viewType, required String url}) {
    return _call(
        type: _WebViewConst.openPage, viewType: viewType, args: {"url": url});
  }

  @override
  bool get supported => Platform.isAndroid || Platform.isMacOS;

  @override
  void addListener(WebViewListener listener) {
    _listeners[listener.viewType] = listener;
  }

  @override
  void removeListener(WebViewListener listener) {
    _listeners.remove(listener.viewType);
  }

  @override
  Future<bool> canGoBack(String viewType) {
    return _call(type: _WebViewConst.canGoBack, viewType: viewType);
  }

  @override
  Future<bool> canGoForward(String viewType) {
    return _call(viewType: viewType, type: _WebViewConst.canGoForward);
  }

  @override
  Future<void> goBack(String viewType) async {
    await _call(viewType: viewType, type: _WebViewConst.goBack);
  }

  @override
  Future<void> goForward(String viewType) async {
    await _call(viewType: viewType, type: _WebViewConst.goForward);
  }

  @override
  Future<void> reload(String viewType) async {
    await _call(viewType: viewType, type: _WebViewConst.reload);
  }

  @override
  Future<void> init(String viewType,
      {String url = "https://google.com", String? jsInterface}) async {
    await _call(
        viewType: viewType,
        type: _WebViewConst.createWebView,
        args: {"url": url, "jsInterface": jsInterface});
  }

  @override
  Future<void> addJsInterface(
      {required String viewType, required String name}) async {
    await _call(
        viewType: viewType,
        type: _WebViewConst.addInterface,
        args: {"name": name});
  }

  @override
  Future<void> removeJsInterface(
      {required String viewType, required String name}) async {
    await _call(
        viewType: viewType,
        type: _WebViewConst.removeInterface,
        args: {"name": name});
  }

  @override
  Future<void> updateFrame(
      {required String viewType, required WidgetSize size}) async {
    await _call(
        viewType: viewType,
        type: _WebViewConst.updateFrame,
        args: {"width": size.width, "height": size.height});
  }

  @override
  Future<void> dispose(String viewType) async {
    await _call(viewType: viewType, type: _WebViewConst.dispose);
  }
}
