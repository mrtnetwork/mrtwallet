import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/core/core.dart';
import 'package:mrt_wallet/provider/api/models/request_completer.dart';
import 'package:mrt_wallet/provider/api/networks/bitcoin/core/electrum_api_provider_service.dart';

import 'electrum_service.dart';

class ElectrumSocketService extends TCPProvider implements ElectrumService {
  ElectrumSocketService({
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
