import '../platform_impl/cross.dart'
    if (dart.library.js_interop) '../platform_impl/web.dart'
    if (dart.library.io) '../platform_impl/io.dart';

abstract class PlatformWebScoket {
  void close({int? code});
  void sink(List<int> message);
  Stream<dynamic> get stream;
  bool get isConnected;
  static Future<PlatformWebScoket> connect(String url,
          {List<String>? protocols}) async =>
      connectSoc(url, protocols: protocols);
}
