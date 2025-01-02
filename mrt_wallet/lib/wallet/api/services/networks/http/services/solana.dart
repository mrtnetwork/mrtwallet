import 'package:blockchain_utils/service/service.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/solana.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaHTTPService extends HTTPService<SolanaAPIProvider>
    implements SolanaServiceProvider {
  SolanaHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;
  @override
  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SolanaRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }

  @override
  final SolanaAPIProvider provider;
}
