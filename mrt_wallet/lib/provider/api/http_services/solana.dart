import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/solana/solana.dart';

class RPCHttpService extends HttpProvider implements SolanaJSONRPCService {
  @override
  final String url;
  @override
  final Duration defaultTimeOut;
  RPCHttpService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  Future<Map<String, dynamic>> call(SolanaRequestDetails params,
      [Duration? timeout]) async {
    final response = await providerPOST<Map<String, dynamic>>(
        url, params.toRequestBody(),
        headers: {'Content-Type': 'application/json'});
    return response;
  }

  @override
  final ApiProviderTracker<SolanaApiProviderService> provider;
}
