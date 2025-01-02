import 'package:blockchain_utils/service/service.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/tron.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/on_chain.dart';

class TronHTTPService extends HTTPService<TronAPIProvider>
    implements TronServiceProvider {
  TronHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;
  @override
  final TronAPIProvider provider;
  @override
  final Duration defaultTimeOut;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TronRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }

  // @override
  // Future<Map<String, dynamic>> post(TronRequestDetails params,
  //     [Duration? timeout]) async {
  //   final response = await providerPOST<Map<String, dynamic>>(
  //       params.url(url), params.toRequestBody(),
  //       timeout: timeout);
  //   return response.bodyAs();
  // }

  // @override
  // final String url;

  // @override
  // Future<Map<String, dynamic>> get(TronRequestDetails params,
  //     [Duration? timeout]) async {
  //   final response = await providerGET<Map<String, dynamic>>(params.url(url),
  //       timeout: timeout);
  //   return response.bodyAs();
  // }
}
