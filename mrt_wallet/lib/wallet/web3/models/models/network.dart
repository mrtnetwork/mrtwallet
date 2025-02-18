import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class Web3ChainNetworkData<NETWORK extends WalletNetwork> {
  final NETWORK network;
  final ProviderIdentifier? serviceIdentifier;
  const Web3ChainNetworkData(
      {required this.network, required this.serviceIdentifier});
}
