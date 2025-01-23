import 'dart:async';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/app/websocket/websocket.dart';

class _WebsocketConst {
  static const String messageEvent = "message";
  static const String closeEvent = "close";
  static const String openEvent = "open";
}

Future<PlatformWebScoket> connectSoc(String url,
        {List<String>? protocols}) async =>
    await WebsocketWeb.connect(url);

class WebsocketWeb implements PlatformWebScoket {
  final JSWebSocket _socket;
  late final StreamController<dynamic> _streamController =
      StreamController<dynamic>()..onCancel = _onCloseStream;
  void _onCloseStream() {
    if (!_socket.isClosed) {
      _socket.close(1000, "closed by client.");
    }
    _onOpen?.cancel();
    _onMessage?.cancel();
    _onClose?.cancel();
    _onClose = null;
    _onMessage = null;
    _onOpen = null;
  }

  Completer<WebsocketWeb>? _connectedCompleter = Completer<WebsocketWeb>();
  StreamSubscription<dynamic>? _onOpen;
  StreamSubscription<dynamic>? _onClose;
  StreamSubscription<dynamic>? _onMessage;
  WebsocketWeb._(this._socket) {
    _onOpen = _socket.stream(_WebsocketConst.openEvent).listen((event) {
      _connectedCompleter?.complete(this);
      _connectedCompleter = null;
      _onOpen?.cancel();
      _onOpen = null;
    });

    _onMessage = _socket.stream(_WebsocketConst.messageEvent).listen((event) {
      _streamController.add(event);
    });

    _onClose = _socket.stream(_WebsocketConst.closeEvent).listen((event) {
      _streamController.close();
      _connectedCompleter?.completeError(
          ApiProviderException(message: "api_http_client_error"));
      _connectedCompleter = null;
    });
  }

  @override
  void close() {
    _streamController.close();
  }

  @override
  bool get isConnected => _socket.isOpen;
  @override
  Stream<dynamic> get stream => _streamController.stream;

  static Future<WebsocketWeb> connect(String url,
      {List<String> protocols = const []}) async {
    final socket =
        WebsocketWeb._(JSWebSocket.create(url, protocols: protocols));
    try {
      return await socket._connectedCompleter!.future;
    } on ApiProviderException {
      rethrow;
    } catch (_) {
      socket.close();
      rethrow;
    }
  }

  @override
  void sink(List<int> message) {
    _socket.send_(message);
  }
}
