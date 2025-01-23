import 'dart:async';
import 'dart:io';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/app/websocket/core/core.dart';

Future<PlatformWebScoket> connectSoc(String url,
        {List<String>? protocols}) async =>
    await WebsocketIO.connect(url);

class WebsocketIO implements PlatformWebScoket {
  final WebSocket _socket;
  late final StreamController<dynamic> _streamController =
      StreamController<dynamic>()..onCancel = _onCloseStream;
  void _onCloseStream() {
    _socket.close(1000, "closed by client.");
  }

  @override
  bool get isConnected => _socket.readyState == WebSocket.open;
  WebsocketIO._(this._socket) {
    _socket.listen(
      (dynamic data) {
        _streamController.add(data);
      },
      onDone: () {
        _streamController.close();
      },
      onError: (dynamic error) {
        _streamController.addError(error);
      },
    );
  }

  @override
  void close() {
    _streamController.close();
  }

  @override
  Stream<dynamic> get stream => _streamController.stream;

  static Future<WebsocketIO> connect(String url,
      {List<String>? protocols}) async {
    try {
      final socket = await WebSocket.connect(url, protocols: protocols);
      return WebsocketIO._(socket);
    } on WebSocketException catch (e) {
      throw ApiProviderException(message: e.message);
    } on TlsException catch (e) {
      throw ApiProviderException(message: e.message);
    }
  }

  @override
  void sink(List<int> message) {
    _socket.add(message);
  }
}
