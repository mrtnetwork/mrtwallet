import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TronHTTPService extends HttpProvider implements TronServiceProvider {
  TronHTTPService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final ApiProviderTracker provider;
  @override
  final Duration defaultTimeOut;

  @override
  Future<Map<String, dynamic>> post(TronRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerPOST<Map<String, dynamic>>(
        params.url(url), params.toRequestBody(),
        timeout: timeout);
    return response;
  }

  @override
  final String url;

  @override
  Future<Map<String, dynamic>> get(TronRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerGET<Map<String, dynamic>>(params.url(url),
        timeout: timeout);
    return response;
  }
}
