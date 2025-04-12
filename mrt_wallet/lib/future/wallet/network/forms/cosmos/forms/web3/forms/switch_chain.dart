import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/cosmos.dart';

class Web3CosmosSwitchCosmosChain extends CosmosWeb3Form {
  final CosmosChain newChain;
  Web3CosmosSwitchCosmosChain({required this.request, required this.newChain});

  @override
  @override
  final Web3CosmosRequest<dynamic, Web3CosmosRequestParam> request;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(response: true);
  }
}
