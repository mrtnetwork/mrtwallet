import 'package:mrt_wallet/models/wallet_models/currency_balance/core/balance_core.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';

class NetworkWithBalanceDetails {
  NetworkWithBalanceDetails(this.totalBalance, this.network);
  final BalanceCore totalBalance;
  final AppNetworkImpl network;
}
