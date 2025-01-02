import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleHTTPService extends HTTPService<RippleAPIProvider>
    implements XRPServiceProvider {
  RippleHTTPService(
      {required this.provider,
      required this.isolate,
      this.defaultTimeOut = const Duration(seconds: 30)});
  @override
  final APPIsolate isolate;

  @override
  String get url => provider.callUrl;

  @override
  final RippleAPIProvider provider;
  @override
  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(XRPRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
