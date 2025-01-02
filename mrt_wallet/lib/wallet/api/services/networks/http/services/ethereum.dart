import 'package:blockchain_utils/service/models/params.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/on_chain.dart';

class EthereumHTTPService extends HTTPService<EthereumAPIProvider>
    implements EthereumServiceProvider {
  EthereumHTTPService({
    required this.provider,
    required this.isolate,
    this.defaultTimeOut = const Duration(seconds: 30),
    this.requestTimeout,
  });
  @override
  final APPIsolate isolate;

  @override
  final EthereumAPIProvider provider;
  @override
  final Duration defaultTimeOut;

  @override
  final Duration? requestTimeout;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(EthereumRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
