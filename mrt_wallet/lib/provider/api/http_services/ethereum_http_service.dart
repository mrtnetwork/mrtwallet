import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

class EthereumHTTPRPCService extends HttpProvider implements JSONRPCService {
  EthereumHTTPRPCService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final ApiProviderTracker provider;
  @override
  final Duration defaultTimeOut;
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
