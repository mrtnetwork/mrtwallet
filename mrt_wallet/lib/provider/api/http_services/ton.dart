import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/core/core.dart';
import 'package:mrt_wallet/provider/api/networks/ton/api_provider/service.dart';
import 'package:ton_dart/ton_dart.dart'
    show TonServiceProvider, TonRequestInfo, TonApiType;

class TonHTTPProvider extends HttpProvider implements TonServiceProvider {
  TonHTTPProvider(
      {required this.provider,
      this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  final Duration defaultTimeOut;

  @override
  ApiProviderTracker<TonAPIProviderService> provider;
  ProviderAuth? get auth => provider.provider.auth;

  @override
  TonApiType get api => provider.provider.apiType;

  late final String? tonApiUrl =
      api == TonApiType.tonApi ? provider.provider.uri : null;
  late final String? tonCenter =
      api == TonApiType.tonCenter ? provider.provider.uri : null;

  @override
  Future<String> get(TonRequestInfo params, {Duration? timeout}) async {
    final String uri =
        params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenter);
    return await providerGET<String>(uri, timeout: timeout, headers: {
      "Accept": "application/json",
      ...params.header,
      if (auth != null) ...{auth!.key: auth!.value}
    });
  }

  @override
  Future<String> post(TonRequestInfo params, {Duration? timeout}) async {
    final String uri =
        params.url(tonApiUrl: tonApiUrl, tonCenterUrl: tonCenter);
    return await providerPOST<String>(uri, params.body,
        headers: {
          if (auth != null) ...{auth!.key: auth!.value},
          "Accept": "application/json",
          "Content-Type": "application/json",
          ...params.header
        },
        timeout: timeout);
  }
}
