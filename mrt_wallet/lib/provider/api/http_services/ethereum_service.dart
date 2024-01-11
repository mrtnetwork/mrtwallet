import 'package:blockchain_utils/string/string.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

class EthereumRPCService with HttpProvider implements JSONRPCService {
  EthereumRPCService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final ApiProviderTracker provider;
  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(ETHRequestDetails params,
      [Duration? timeout]) async {
    try {
      final response = await client
          .post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: params.toRequestBody())
          .timeout(timeout ?? defaultTimeOut);
      if (response.statusCode != 200) {
        throw ApiProviderException(statusCode: response.statusCode);
      }
      return StringUtils.toJson(StringUtils.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiProviderException(message: "invalid_json_response");
    } catch (e) {
      rethrow;
    }
  }

  @override
  final String url;
}
