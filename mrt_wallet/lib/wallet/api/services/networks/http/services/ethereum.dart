import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/on_chain.dart';

class EthereumHTTPService extends HTTPService<EthereumAPIProvider>
    implements JSONRPCService {
  EthereumHTTPService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30), this.requestTimeout});
  @override
  final EthereumAPIProvider provider;
  @override
  final Duration defaultTimeOut;

  @override
  final Duration? requestTimeout;
  @override
  Future<Map<String, dynamic>> call(ETHRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerPOST<Map<String, dynamic>>(
        url, params.toRequestBody(),
        timeout: timeout);
    return response;
  }

  @override
  final String url;
}
