import 'package:mrt_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:on_chain/on_chain.dart';

class EthereumWebsocketService extends WebSocketService
    implements JSONRPCService {
  EthereumWebsocketService(
      {required super.url,
      required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(ETHRequestDetails params,
      [Duration? timeout]) async {
    final SocketRequestCompeleter message =
        SocketRequestCompeleter(params.params, params.id);
    return await addMessage(message, timeout ?? defaultTimeOut);
  }
}
