import 'webview_event.dart';

typedef OnWebViewEvent = void Function(WebViewEvent);

abstract mixin class WebViewListener {
  String? get viewType;
  void onPageStart(WebViewEvent event) {}
  void onPageError(WebViewEvent event) {}
  void onPageFinished(WebViewEvent event) {}
  void onPageProgress(WebViewEvent event) {}
  void onPageRequest(WebViewEvent event) {}
}
