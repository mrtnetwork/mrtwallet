import 'package:mrt_wallet/wallet/api/provider/networks/stellar.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:http/http.dart' as http;

class StellarHTTPService extends HTTPService<StellarAPIProvider>
    implements StellarServiceProvider {
  @override
  final Duration defaultTimeOut;
  StellarHTTPService(this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final StellarAPIProvider provider;

  @override
  Future<HorizonServiceResponse> get(HorizonRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerGET<http.Response>(
        params.url(
            horizonUri: provider.horizonUrl, sorobanUri: provider.sorobanUrl),
        allowStatus: const []);
    return HorizonServiceResponse(
        body: response.body, statusCode: response.statusCode);
  }

  @override
  Future<HorizonServiceResponse> post(HorizonRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerPOST<http.Response>(
        params.url(
            horizonUri: provider.horizonUrl, sorobanUri: provider.sorobanUrl),
        params.body,
        headers: params.header,
        allowStatus: const []);
    return HorizonServiceResponse(
        body: response.body, statusCode: response.statusCode);
  }
}
