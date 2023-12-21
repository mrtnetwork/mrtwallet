import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/core/http_provider.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RPCV2Service with HttpProvider implements RpcService {
  RPCV2Service(this.url, this.provider,
      {this.defaultTimeOut = const Duration(seconds: 30)});

  @override
  final String url;

  final ApiProviderTracker provider;
  final Duration defaultTimeOut;

  /// When the request is successful, an [RPCResponse] with the request id and
  /// the data from the server will be returned. If not, an RPCError will be
  /// thrown. Other errors might be thrown if an IO-Error occurs.
  @override
  Future<Map<String, dynamic>> call(RPCRequestDetails params) async {
    final response = await providerCaller<Map<String, dynamic>>(() async {
      final response = await client
          .post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: StringUtils.fromJson(params.toJsonRpcParams()))
          .timeout(defaultTimeOut);
      return StringUtils.toJson(StringUtils.decode(response.bodyBytes));
    }, provider);

    return response;
  }

  @override
  Future<String> post(String url, String body,
      {Map<String, String>? header}) async {
    final response = await client
        .post(Uri.parse(url),
            headers: header ?? {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));
    return response.body;
  }
}
