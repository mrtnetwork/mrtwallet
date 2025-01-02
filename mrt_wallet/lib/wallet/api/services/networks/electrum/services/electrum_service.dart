import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/api/services/networks/electrum/electrum.dart';

abstract class ElectrumService with ElectrumServiceProvider {
  ElectrumService();
  factory ElectrumService.fromProvider(ElectrumAPIProvider provider) {
    switch (provider.protocol) {
      case ServiceProtocol.ssl:
        return ElectrumSSLSocketService(provider: provider);
      case ServiceProtocol.tcp:
        return ElectrumSocketService(provider: provider);
      default:
        return ElectrumWebsocketService(provider: provider);
    }
  }
}
