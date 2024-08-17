import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateHttpService extends HTTPService<SubstrateAPIProvider>
    with SubstrateRPCService {
  @override
  final SubstrateAPIProvider provider;

  @override
  final Duration defaultTimeOut;

  SubstrateHttpService(this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  String get url => provider.callUrl;
  @override
  Future<Map<String, dynamic>> call(SubstrateRequestDetails params,
      [Duration? timeout]) async {
    final response =
        await providerPOST<Map<String, dynamic>>(url, params.toRequestBody());

    return response;
  }
}
