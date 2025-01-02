import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart' show ApiService;
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/bitcoin.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';

class BitcoinHTTPService extends HTTPService<BitcoinExplorerAPIProvider>
    implements ApiService {
  BitcoinHTTPService({
    required this.provider,
    required this.isolate,
    this.defaultTimeOut = const Duration(seconds: 30),
  });
  @override
  final APPIsolate isolate;

  @override
  final BitcoinExplorerAPIProvider provider;
  @override
  final Duration defaultTimeOut;
  @override
  Future<T> get<T>(String url) async {
    final result = await providerGET<T>(url);
    return result.bodyAs();
  }

  @override
  Future<T> post<T>(String url,
      {Map<String, String>? headers, Object? body}) async {
    final response = await providerPOST<T>(url, body as String?,
        allowStatus: provider.explorerType.isBlockCypher ? [200, 201] : [200]);
    return response.bodyAs();
  }
}
