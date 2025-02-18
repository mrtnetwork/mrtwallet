import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/aptos.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/aptos/src/aptos.dart';

class AptosHTTPService extends HTTPService<AptosAPIProvider>
    implements AptosServiceProvider {
  AptosHTTPService({
    required this.provider,
    required this.isolate,
    required this.graphQlProvider,
    this.defaultTimeOut = const Duration(seconds: 30),
  });
  @override
  final AptosAPIProvider provider;
  final AptosAPIProvider graphQlProvider;
  @override
  final APPIsolate isolate;
  @override
  final Duration defaultTimeOut;

  @override
  Future<AptosServiceResponse<T>> doRequest<T>(AptosRequestDetails params,
      {Duration? timeout}) async {
    final Uri uri = params.aptosRequestType == AptosRequestType.fullnode
        ? params.toUri(provider.callUrl)
        : params.toUri(graphQlProvider.callUrl);
    final AptosAPIProvider currentProvider =
        params.aptosRequestType == AptosRequestType.fullnode
            ? provider
            : graphQlProvider;
    return await serviceRequest<T>(params,
        uri: uri,
        allowStatus: [200, 202, 206],
        timeout: timeout,
        currentProvider: currentProvider);
  }
}
