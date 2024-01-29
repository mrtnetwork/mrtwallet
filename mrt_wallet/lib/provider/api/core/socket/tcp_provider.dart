import 'dart:async';
import 'dart:io';

import 'package:blockchain_utils/string/string.dart';
import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utility/method_caller.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/api/core/socket/socket_provider.dart';
import 'package:mrt_wallet/provider/api/models/request_completer.dart';
import 'package:mrt_wallet/provider/api/models/socket_status.dart';

class TCPProvider extends BaseSocketProvider {
  TCPProvider({required this.url, required this.provider});
  @override
  final ApiProviderTracker<ApiProviderService> provider;
  @override
  final String url;

  final _lock = SynchronizedLock();
  Socket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<List<int>>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;
  List<int> _toRequest(String params) {
    final req = "$params\n";
    return StringUtils.encode(req);
  }

  final Map<int, SocketRequestCompeleter> _requests = {};
  void _add(List<int> message) {
    _socket?.add(message);
  }

  void _onClose() {
    _status = SocketStatus.disconnect;
    _socket?.close().catchError((e) => null);
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
    _socket = null;
  }

  @override
  void close() => _onClose();

  void _onMessge(List<int> event) {
    final Map<String, dynamic> decode =
        StringUtils.toJson(StringUtils.decode(event));
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
        final result = url.split(":");
        final socket = await Socket.connect(result.first, int.parse(result[1]));
        return socket;
      });
      if (result.hasResult) {
        _status = SocketStatus.connect;
        _socket = result.result;
        _subscription = _socket?.listen(_onMessge, onDone: _onClose);
      } else {
        _status = SocketStatus.disconnect;
      }
    });
  }

  Future<Map<String, dynamic>> post(
      SocketRequestCompeleter message, Duration timeout) async {
    try {
      return providerCaller(() async {
        _requests[message.id] = message;
        _add(_toRequest(message.params));
        final result = await message.completer.future.timeout(timeout);
        return result;
      }, message);
    } finally {
      _requests.remove(message.id);
    }
  }
}
