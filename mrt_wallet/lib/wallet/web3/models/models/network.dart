import 'package:mrt_wallet/wallet/models/models.dart';

class Web3ChainNetworkData<NETWORK extends WalletNetwork> {
  final NETWORK network;
  final String? serviceIdentifier;
  const Web3ChainNetworkData(
      {required this.network, required this.serviceIdentifier});
}
