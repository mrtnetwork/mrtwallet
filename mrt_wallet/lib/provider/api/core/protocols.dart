import 'package:mrt_native_support/models/platform.dart';
import 'package:mrt_wallet/app/core.dart';

enum ProviderProtocol {
  http("HTTP", 0),
  ssl("SSL", 1),
  tcp("TCP", 2),
  websocket("WebSocket", 3);

  const ProviderProtocol(this.value, this.id);
  final String value;
  final int id;

  List<AppPlatform> get platforms {
    switch (this) {
      case ProviderProtocol.http:
      case ProviderProtocol.websocket:
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

  static ProviderProtocol fromID(int id, {ProviderProtocol? orElese}) {
    return ProviderProtocol.values.firstWhere((element) => element.id == id,
        orElse: orElese == null ? null : () => orElese);
  }

  static ProviderProtocol fromURI(String url) {
    final lower = url.toLowerCase();
    if (lower.startsWith("http")) {
      return ProviderProtocol.http;
    } else if (lower.startsWith("ws")) {
      return ProviderProtocol.websocket;
    } else {
      throw WalletException(
          "Invalid URL. The ProviderProtocol.fromURI function is designed to work exclusively with http and websocket URIs.");
    }
  }

  @override
  String toString() {
    return value;
  }
}
