import 'package:mrt_wallet/provider/api/core/socket/websocket_provider.dart';
import 'package:mrt_wallet/provider/api/models/request_completer.dart';
import 'package:on_chain/on_chain.dart';

class EthereumWebsocketCService extends WebSocketProvider
    implements JSONRPCService {
  EthereumWebsocketCService(
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
