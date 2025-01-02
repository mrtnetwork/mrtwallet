import 'package:blockchain_utils/service/models/params.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/core.dart';
import 'package:on_chain/ada/src/provider/service/service.dart';

class CardanoHTTPService extends HTTPService<CardanoAPIProvider>
    implements BlockFrostServiceProvider {
  CardanoHTTPService({
    required this.provider,
    required this.isolate,
    this.version = "v0",
    this.defaultTimeOut = const Duration(seconds: 30),
  });
  @override
  final APPIsolate isolate;

  final String version;

  String get url => provider.callUrl;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(BlockFrostRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(url, version: version), allowStatus: [200, 404, 400]);
  }

  @override
  final Duration defaultTimeOut;

  @override
  final CardanoAPIProvider provider;
}
