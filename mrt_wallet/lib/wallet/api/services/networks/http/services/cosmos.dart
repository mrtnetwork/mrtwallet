import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';

class TendermintHTTPService extends HTTPService<CosmosAPIProvider>
    implements TendermintServiceProvider {
  TendermintHTTPService({
    required this.url,
    required this.provider,
    this.defaultTimeOut = const Duration(seconds: 30),
  });
  @override
  final String url;
  @override
  Future<Map<String, dynamic>> get(TendermintRequestDetails params,
      [Duration? timeout]) async {
    return await providerGET<Map<String, dynamic>>(params.url(url),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json"
        },
        timeout: timeout);
  }

  @override
  Future<dynamic> post(TendermintRequestDetails params,
      [Duration? timeout]) async {
    return await providerPOST(params.url(url), params.body,
        headers: {"Accept": "application/json", ...params.header},
        timeout: timeout);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CosmosAPIProvider provider;
}
