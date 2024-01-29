import 'dart:async';

import 'package:blockchain_utils/string/string.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/websocket/core/core.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/api/core/socket/socket_provider.dart';
import 'package:mrt_wallet/provider/api/models/request_completer.dart';
import 'package:mrt_wallet/provider/api/models/socket_status.dart';

class WebSocketProvider extends BaseSocketProvider {
  WebSocketProvider({required this.url, required this.provider});
  @override
  final ApiProviderTracker<ApiProviderService> provider;
  @override
  final String url;

  final _lock = SynchronizedLock();
  PlatformWebScoket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<String>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;

  final Map<int, SocketRequestCompeleter> _requests = {};
  void _add(List<int> message) {
    _socket?.sink(message);
  }

  void _onClose() {
    _status = SocketStatus.disconnect;
    _socket?.close();
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
    _socket = null;
  }

  @override
  void close() => _onClose();

  void _onMessge(String event) {
    final Map<String, dynamic> decode = StringUtils.toJson(event);
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = _requests.remove(id);
      request?.completer.complete(decode);
    }
  }

  @override
  Future<void> connect() async {
    await _lock.synchronized(() async {
      if (_status != SocketStatus.disconnect) return;
      final result = await MethodCaller.call(() async {
        final socket = await PlatformWebScoket.connect(url);
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription =
            _socket?.stream.cast<String>().listen(_onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;

        throw result.exception!;
      }
    });
  }

  Future<Map<String, dynamic>> addMessage(
      SocketRequestCompeleter message, Duration timeout) async {
    try {
      return providerCaller(() async {
        _requests[message.id] = message;
        _add(StringUtils.encode(message.params));
        final result = await message.completer.future.timeout(timeout);
        return result;
      }, message);
    } finally {
      _requests.remove(message.id);
    }
  }
}
