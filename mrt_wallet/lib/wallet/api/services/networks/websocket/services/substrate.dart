import 'package:blockchain_utils/service/models/params.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateWebsocketService extends WebSocketService<SubstrateAPIProvider>
    with SubstrateServiceProvider {
  SubstrateWebsocketService(
      {required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
