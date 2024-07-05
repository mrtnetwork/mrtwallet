import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/services/networks/electrum/electrum.dart';

abstract class ElectrumService with BitcoinBaseElectrumRPCService {
  ElectrumService();
  factory ElectrumService.fromProvider({
    required ElectrumAPIProvider provider,
    required ElectrumAPIProvider service,
  }) {
    switch (service.protocol) {
      case ServiceProtocol.ssl:
        return ElectrumSSLSocketService(
            url: service.endpoint, provider: provider);
      case ServiceProtocol.tcp:
        return ElectrumSocketService(url: service.endpoint, provider: provider);
      default:
        return ElectrumWebsocketService(
            url: service.endpoint, provider: provider);
    }
  }
}
