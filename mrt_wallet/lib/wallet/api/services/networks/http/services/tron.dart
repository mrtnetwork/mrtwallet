import 'package:mrt_wallet/wallet/api/provider/networks/tron.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/on_chain.dart';

class TronHTTPService extends HTTPService<TronAPIProvider>
    implements TronServiceProvider {
  TronHTTPService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final TronAPIProvider provider;
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
