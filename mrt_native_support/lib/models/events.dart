abstract mixin class NativeEvents {}

class NetworkEvent extends NativeEvents {
  NetworkEvent.none() : _status = "none";
  NetworkEvent.fromJson(Map<String, dynamic> json) : _status = json["data"];
  final String _status;

  bool get isConnected => _status != "none";
}
