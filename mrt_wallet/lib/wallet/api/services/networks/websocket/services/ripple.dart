import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleWebsocketService extends WebSocketService<RippleAPIProvider>
    implements RpcService {
  RippleWebsocketService(
      {required super.url,
      required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(RPCRequestDetails params,
      [Duration? timeout]) async {
    final SocketRequestCompeleter message = SocketRequestCompeleter(
        StringUtils.fromJson(params.toWebsocketParams()), params.id);
    return await addMessage(message, timeout ?? defaultTimeOut);
  }

  @override
  Future<String> post(String url, String body, {Map<String, String>? header}) {
    throw UnimplementedError();
  }
}
