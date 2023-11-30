import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum ApiProviderService {
  blockCypher("BlockCypher", "https://www.blockcypher.com/"),
  mempool("Mempool", "https://mempool.space/");

  final String serviceName;
  final String websiteUri;
  const ApiProviderService(this.serviceName, this.websiteUri);
  static ApiProviderService fromServiceName(String name) {
    return values.firstWhere((element) => element.serviceName == name);
  }
}

abstract class NetworkApiProvider {
  Future<void> updateBalance(CryptoAddress account);
  abstract final AppNetworkImpl network;
  abstract final ApiProviderTracker serviceProvider;
}
