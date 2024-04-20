import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/ada/src/provider/blockfrost/core/core.dart';
import 'package:on_chain/ada/src/provider/service/service.dart';

class CardaboHttpProvider extends HttpProvider
    implements BlockfrostServiceProvider {
  CardaboHttpProvider(
      {required this.url,
      required this.provider,
      this.version = "v0",
      this.projectId,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final String url;
  final String version;
  final String? projectId;

  @override
  Future<dynamic> get(BlockforestRequestDetails params,
      [Duration? timeout]) async {
    return await providerGET(params.url(url, version), headers: {
      'Content-Type': 'application/json',
      "Accept": "application/json",
      if (projectId != null) ...{"project_id": projectId!},
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
      if (projectId != null) ...{"project_id": projectId!},
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
  final ApiProviderTracker<ApiProviderService> provider;
}
