import 'package:blockchain_utils/service/service.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/stellar.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarHTTPService extends HTTPService<StellarAPIProvider>
    implements StellarServiceProvider {
  StellarHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;
  @override
  final Duration defaultTimeOut;
  @override
  final StellarAPIProvider provider;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(StellarRequestDetails params,
      {Duration? timeout}) async {
    final corretUrl = params.apiType == StellarAPIType.horizon
        ? provider.callUrl
        : provider.sorobanUrl;
    final r = await serviceRequest<T>(params,
        uri: params.toUri(corretUrl), allowStatus: [200], timeout: timeout);
    return r;
  }
}
