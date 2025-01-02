import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';
import 'package:mrt_wallet/wallet/api/services/impl/protocols.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'electrum_service.dart';

class ElectrumSSLSocketService extends SSLService<ElectrumAPIProvider>
    implements ElectrumService {
  ElectrumSSLSocketService({
    required super.provider,
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  });
  final Duration defaultRequestTimeOut;
  String get url => provider.callUrl;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ElectrumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await post(message, timeout ?? defaultRequestTimeOut);
    return params.toResponse(r);
  }
}
