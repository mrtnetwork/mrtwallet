import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

enum ServiceProtocol {
  http("HTTP", 0),
  ssl("SSL", 1),
  tcp("TCP", 2),
  websocket("WebSocket", 3);

  const ServiceProtocol(this.value, this.id);
  final String value;
  final int id;

  List<AppPlatform> get platforms {
    switch (this) {
      case ServiceProtocol.http:
      case ServiceProtocol.websocket:
        return AppPlatform.values;
      default:
        return [
          AppPlatform.android,
          AppPlatform.windows,
          AppPlatform.ios,
          AppPlatform.macos
        ];
    }
  }

  bool supportOnThisPlatform(AppPlatform platform) {
    return platforms.contains(platform);
  }

  static ServiceProtocol fromID(int id, {ServiceProtocol? orElese}) {
    return ServiceProtocol.values.firstWhere((element) => element.id == id,
        orElse: orElese == null ? null : () => orElese);
  }

  static ServiceProtocol fromURI(String url) {
    final lower = url.toLowerCase();
    if (lower.startsWith("http")) {
      return ServiceProtocol.http;
    } else if (lower.startsWith("ws")) {
      return ServiceProtocol.websocket;
    } else {
      throw WalletException(
          "Invalid URL. The ServiceProtocol.fromURI function is designed to work exclusively with http and websocket URIs.");
    }
  }

  @override
  String toString() {
    return value;
  }
}
