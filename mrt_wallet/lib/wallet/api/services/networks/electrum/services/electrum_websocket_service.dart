import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';

class ElectrumWebsocketService extends WebSocketService<ElectrumAPIProvider>
    implements ElectrumService {
  ElectrumWebsocketService(
      {required super.provider,
      this.defaultRequestTimeOut = const Duration(seconds: 30)});
  final Duration defaultRequestTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ElectrumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultRequestTimeOut);
    return params.toResponse(r);
  }
}
