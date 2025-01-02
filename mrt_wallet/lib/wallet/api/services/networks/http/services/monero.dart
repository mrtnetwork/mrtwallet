import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/monero.dart';
import 'package:mrt_wallet/wallet/api/services/impl/http/http.dart';

class MoneroHTTPService extends HTTPService<MoneroAPIProvider>
    implements MoneroServiceProvider {
  @override
  final Duration defaultTimeOut;
  @override
  final APPIsolate isolate;
  MoneroHTTPService(this.provider,
      {this.defaultTimeOut = const Duration(minutes: 1),
      this.isolate = APPIsolate.separate});

  @override
  final MoneroAPIProvider provider;
  @override
  Future<BaseServiceResponse<T>> doRequest<T>(MoneroRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(provider.callUrl),
        allowStatus: [200],
        timeout: timeout);
  }
}
