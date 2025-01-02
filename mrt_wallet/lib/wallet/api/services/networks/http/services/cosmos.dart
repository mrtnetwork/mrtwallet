import 'package:blockchain_utils/service/service.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';

class TendermintHTTPService extends HTTPService<CosmosAPIProvider>
    implements TendermintServiceProvider {
  TendermintHTTPService({
    required this.provider,
    required this.isolate,
    this.defaultTimeOut = const Duration(seconds: 30),
  });
  @override
  final APPIsolate isolate;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TendermintRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl), allowStatus: [200]);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CosmosAPIProvider provider;
}
