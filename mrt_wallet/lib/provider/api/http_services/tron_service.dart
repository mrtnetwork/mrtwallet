import 'package:blockchain_utils/string/string.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TronHTTPService with HttpProvider implements TronServiceProvider {
  TronHTTPService(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final ApiProviderTracker provider;
  final Duration defaultTimeOut;

  @override
  Future<Map<String, dynamic>> post(TronRequestDetails params,
      [Duration? timeout]) async {
    final response = await client
        .post(Uri.parse(params.url(url)),
            headers: {'Content-Type': 'application/json'},
            body: params.toRequestBody())
        .timeout(timeout ?? defaultTimeOut);
    if (response.statusCode != 200) {
      throw ApiProviderException(statusCode: response.statusCode);
    }
    return StringUtils.toJson(StringUtils.decode(response.bodyBytes));
  }

  @override
  final String url;

  @override
  Future<Map<String, dynamic>> get(TronRequestDetails params,
      [Duration? timeout]) async {
    final response = await client.get(Uri.parse(params.url(url)), headers: {
      'Content-Type': 'application/json'
    }).timeout(timeout ?? defaultTimeOut);
    if (response.statusCode != 200) {
      throw ApiProviderException(statusCode: response.statusCode);
    }
    return StringUtils.toJson(StringUtils.decode(response.bodyBytes));
  }
}
