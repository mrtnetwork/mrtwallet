import 'wallet_event.dart';

class WebViewEvent {
  final String viewId;
  final String eventName;
  final String? url;
  final String? favicon;
  final String? originalUrl;
  final String? title;
  final String? message;
  final int? progress;
  final WalletEvent? request;
  const WebViewEvent(
      {required this.eventName,
      required this.viewId,
      this.url,
      this.favicon,
      this.originalUrl,
      this.title,
      this.message,
      this.progress,
      this.request});
  factory WebViewEvent.fromJson(Map<String, dynamic> json) {
    return WebViewEvent(
        eventName: json["eventName"],
        viewId: json["id"],
        url: json["url"],
        favicon: json["favicon"],
        message: json["message"],
        originalUrl: json["originalUrl"],
        progress: json["progress"],
        title: json["title"],
        request: json["request"] == null
            ? null
            : WalletEvent.fromJson((json["request"] as Map).cast()));
  }
}
