import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/core.dart';
import 'package:on_chain/ada/src/provider/service/service.dart';

class CardanoHTTPService extends HTTPService<CardanoAPIProvider>
    implements BlockfrostServiceProvider {
  CardanoHTTPService(
      {required this.provider,
      this.version = "v0",
      this.defaultTimeOut = const Duration(seconds: 30)});

  final String version;
  @override
  String get url => provider.callUrl;
  ProviderAuth? get auth => provider.auth;

  @override
  Future<dynamic> get(BlockforestRequestDetails params,
      [Duration? timeout]) async {
    return await providerGET(params.url(url, version), headers: {
      "Accept": "application/json",
      if (auth != null) ...{auth!.key: auth!.value},
    }, allowStatus: [
      200,
      404,
      400
    ]);
  }

  @override
  Future<dynamic> post(BlockforestRequestDetails params,
      [Duration? timeout]) async {
    return await providerPOST(params.url(url, version), params.body, headers: {
      "Accept": "application/json",
      if (auth != null) ...{auth!.key: auth!.value},
      ...params.header
    }, allowStatus: [
      200,
      404,
      400
    ]);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CardanoAPIProvider provider;
}
