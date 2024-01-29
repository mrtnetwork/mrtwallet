import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart' show ApiService;
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class BitcoinApiService extends HttpProvider implements ApiService {
  BitcoinApiService(this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  final ApiProviderTracker provider;
  @override
  final Duration defaultTimeOut;
  @override
  Future<T> get<T>(String url) async {
    final result = await providerGET<T>(url);
    return result;
  }

  @override
  Future<T> post<T>(String url,
      {Map<String, String> headers = const {"Content-Type": "application/json"},
      Object? body}) async {
    final response = await providerPOST<T>(url, body as String?,
        allowStatus: provider.provider == ApiProviderService.blockCypher
            ? [200, 201]
            : [200],
        headers: headers);
    return response;
  }
}
