import 'package:mrt_wallet/wallet/api/provider/networks/solana.dart';
import 'package:mrt_wallet/wallet/api/services/core/tracker.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaHTTPService extends HTTPService implements SolanaJSONRPCService {
  @override
  final String url;
  @override
  final Duration defaultTimeOut;
  SolanaHTTPService(this.url, this.provider,
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
  final APIServiceTracker<SolanaAPIProvider> provider;
}
