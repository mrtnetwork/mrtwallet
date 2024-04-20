import 'dart:convert';
import 'package:http/http.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/solana/solana.dart';

class RPCHttpService extends HttpProvider implements SolanaJSONRPCService {
  RPCHttpService(this.url, this.provider,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  @override
  final String url;
  @override
  final Client client;
  @override
  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(SolanaRequestDetails params,
      [Duration? timeout]) async {
    final response = await client
        .post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: params.toRequestBody())
        .timeout(timeout ?? defaultTimeOut);
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  }

  @override
  final ApiProviderTracker<SolanaApiProviderService> provider;
}
