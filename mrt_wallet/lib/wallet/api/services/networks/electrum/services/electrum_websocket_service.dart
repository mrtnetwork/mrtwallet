import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';

class ElectrumWebsocketService extends WebSocketService
    implements ElectrumService {
  ElectrumWebsocketService({
    required super.url,
    required APIServiceTracker<ElectrumAPIProvider> super.provider,
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  });
  final Duration defaultRequestTimeOut;

  @override
  Future<Map<String, dynamic>> call(ElectrumRequestDetails params,
      [Duration? timeout]) async {
    final SocketRequestCompeleter message =
        SocketRequestCompeleter(StringUtils.fromJson(params.params), params.id);
    return await addMessage(message, timeout ?? defaultRequestTimeOut);
  }

  @override
  APIServiceTracker<ElectrumAPIProvider> get provider =>
      super.provider as APIServiceTracker<ElectrumAPIProvider>;
}
