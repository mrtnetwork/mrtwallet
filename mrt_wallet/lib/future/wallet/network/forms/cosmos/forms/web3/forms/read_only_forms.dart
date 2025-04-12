import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/cosmos.dart';

class Web3CosmosReadOnlyForm<PARAMS extends Web3CosmosRequestParam>
    extends CosmosWeb3Form<PARAMS> {
  Web3CosmosReadOnlyForm({required this.request});

  @override
  Web3CosmosRequest<dynamic, PARAMS> request;
}
