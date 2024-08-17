import 'dart:async';
import 'package:mrt_wallet/app/websocket/core/core.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

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
  final StreamController<dynamic> _streamController =
      StreamController<dynamic>();
  final Completer<void> _connectedCompleter = Completer<void>();
  StreamSubscription<dynamic>? _onOpen;
  StreamSubscription<dynamic>? _onClose;
  StreamSubscription<dynamic>? _onMessage;
  WebsocketWeb._(this._socket) {
    _onOpen = _socket.stream(_WebsocketConst.openEvent).listen((event) {
      _connectedCompleter.complete();
      _onOpen?.cancel();
      _onOpen = null;
    });

    _onMessage = _socket.stream(_WebsocketConst.messageEvent).listen((event) {
      _streamController.add(event);
    });

    _onClose = _socket.stream(_WebsocketConst.closeEvent).listen((event) {
      _streamController.close();
    });
  }

  @override
  void close({int? code, String? reason}) {
    if (!_socket.isClosed) {
      _socket.close(code ?? 1000, reason);
    }
    _onOpen?.cancel();
    _onMessage?.cancel();
    _onClose?.cancel();
    _onClose = null;
    _onMessage = null;
    _onOpen = null;
  }

  @override
  bool get isConnected => _socket.isOpen;
  @override
  Stream<dynamic> get stream => _streamController.stream;

  static Future<WebsocketWeb> connect(String url,
      {List<String> protocols = const []}) async {
    final completer = Completer<WebsocketWeb>();
    final socket = JSWebSocket.create(url, protocols: protocols);
    try {
      WebsocketWeb._(socket)._connectedCompleter.future.then((_) {
        completer.complete(WebsocketWeb._(socket));
      });
      return completer.future;
    } catch (e) {
      socket.close();
      rethrow;
    }
  }

  @override
  void sink(List<int> message) {
    _socket.send_(message);
  }
}
