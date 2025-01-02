import 'package:blockchain_utils/service/service.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:ton_dart/ton_dart.dart'
    show TonApiType, TonRequestDetails, TonServiceProvider;

class TonHTTPService extends HTTPService<TonAPIProvider>
    implements TonServiceProvider {
  TonHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;
  @override
  final Duration defaultTimeOut;

  @override
  final TonAPIProvider provider;
  @override
  TonApiType get api => provider.apiType;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(TonRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
