import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:ton_dart/ton_dart.dart'
    show TonServiceProvider, TonRequestInfo, TonApiType;

class TonHTTPService extends HTTPService<TonAPIProvider>
    implements TonServiceProvider {
  TonHTTPService(
      {required this.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  final Duration defaultTimeOut;

  @override
  final TonAPIProvider provider;
  ProviderAuth? get auth => provider.auth;

  @override
  TonApiType get api => provider.apiType;

  late final String? tonApiUrl = api == TonApiType.tonApi ? provider.uri : null;
  late final String? tonCenter =
      api == TonApiType.tonCenter ? provider.uri : null;

  @override
  Future<String> get(TonRequestInfo params, {Duration? timeout}) async {
    final String uri =
        params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenter);
    return await providerGET<String>(uri,
        timeout: timeout,
        headers: {"Accept": "application/json", ...params.header});
  }

  @override
  Future<String> post(TonRequestInfo params, {Duration? timeout}) async {
    final String uri =
        params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenter);
    return await providerPOST<String>(uri, params.body,
        headers: {"Accept": "application/json", ...params.header},
        timeout: timeout);
  }
}
