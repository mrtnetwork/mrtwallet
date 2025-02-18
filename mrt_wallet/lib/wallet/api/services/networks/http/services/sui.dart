import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/sui.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/sui/sui.dart';

class SuiHTTPService extends HTTPService<SuiAPIProvider>
    implements SuiServiceProvider {
  SuiHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;
  @override
  final Duration defaultTimeOut;

  @override
  Future<SuiServiceResponse<T>> doRequest<T>(SuiRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }

  @override
  final SuiAPIProvider provider;
}
