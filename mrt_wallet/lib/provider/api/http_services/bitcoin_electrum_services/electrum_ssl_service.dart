import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class ElectrumSSLSocketService extends SSLProvider implements ElectrumService {
  ElectrumSSLSocketService({
    required super.url,
    required ApiProviderTracker<ElectrumApiProviderService> super.provider,
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  });
  final Duration defaultRequestTimeOut;
  @override
  Future<Map<String, dynamic>> call(ElectrumRequestDetails params,
      [Duration? timeout]) async {
    final SocketRequestCompeleter message =
        SocketRequestCompeleter(StringUtils.fromJson(params.params), params.id);
    return await post(message, timeout ?? defaultRequestTimeOut);
  }

  @override
  ApiProviderTracker<ElectrumApiProviderService> get provider =>
      super.provider as ApiProviderTracker<ElectrumApiProviderService>;
}
