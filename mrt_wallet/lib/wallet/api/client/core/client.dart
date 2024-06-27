import 'package:mrt_wallet/wallet/api/services/core/tracker.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';

abstract class NetworkClient<T> {
  const NetworkClient();
  abstract final WalletNetwork network;
  Future<void> updateBalance(T account);
  abstract final APIServiceTracker serviceProvider;
}
