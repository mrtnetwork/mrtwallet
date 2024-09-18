import 'package:mrt_native_support/exception/exception.dart';

enum WalletEventTypes {
  message,
  exception,
  activation,
  tabId,
  ping,
  popup,
  windowId,
  openExtension;

  static WalletEventTypes fromName(String name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () =>
            throw MRTNativePluginException("Invalid wallet event type $name"));
  }
}

class WalletEvent {
  final String clientId;
  final List<int> data;
  final String requestId;
  final WalletEventTypes type;
  final String? additional;
  WalletEvent(
      {required this.clientId,
      required List<int> data,
      required this.requestId,
      required this.type,
      this.additional})
      : data = List<int>.unmodifiable(data);
  factory WalletEvent.fromJson(Map<String, dynamic> json) {
    return WalletEvent(
        clientId: json["client_id"],
        data: List<int>.from(json["data"]),
        requestId: json["request_id"],
        type: WalletEventTypes.fromName(json["type"]),
        additional: json["additional"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "client_id": clientId,
      "data": data,
      "request_id": requestId,
      "type": type.name,
      "additional": additional,
    };
  }
}
