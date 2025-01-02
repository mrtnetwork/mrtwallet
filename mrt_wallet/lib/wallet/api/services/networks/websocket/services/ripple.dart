import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/services/impl/socket/protocols/websocket.dart';
import 'package:mrt_wallet/wallet/api/services/models/models/request_completer.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleWebsocketService extends WebSocketService<RippleAPIProvider>
    implements XRPServiceProvider {
  RippleWebsocketService(
      {required super.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;
  @override
  Future<XRPServiceResponse<T>> doRequest<T>(XRPRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body(websoket: true)!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
