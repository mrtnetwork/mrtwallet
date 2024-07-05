import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

abstract class NetworkClient<T, P extends APIProvider> {
  const NetworkClient();
  abstract final WalletNetwork network;
  Future<void> updateBalance(T account);
  // abstract final APIServiceTracker serviceProvider;
  abstract final BaseServiceProtocol<P> service;
}
