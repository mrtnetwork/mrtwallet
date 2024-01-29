import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

abstract class ElectrumService with BitcoinBaseElectrumRPCService {
  ElectrumService();
  factory ElectrumService.fromProvider({
    required ApiProviderTracker<ElectrumApiProviderService> provider,
    required ElectrumApiProviderService service,
  }) {
    switch (service.protocol) {
      case ProviderProtocol.ssl:
        return ElectrumSSLSocketService(
            url: service.endpoint, provider: provider);
      case ProviderProtocol.tcp:
        return ElectrumSocketService(url: service.endpoint, provider: provider);
      default:
        return ElectrumWebsocketService(
            url: service.endpoint, provider: provider);
    }
  }
}
