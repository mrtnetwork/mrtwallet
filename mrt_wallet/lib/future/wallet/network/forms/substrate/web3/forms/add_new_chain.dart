import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateAddNewChainForm
    extends SubstrateWeb3Form<Web3SubstrateAddNewChain> {
  Web3SubstrateAddNewChainForm({required this.request, required this.chain});

  final SubstrateChain? chain;

  @override
  Web3SubstrateRequest<bool, Web3SubstrateAddNewChain> request;
  Web3SubstrateAddNewChain get params => request.params;
  @override
  OnChangeForm? onChanged;
}
