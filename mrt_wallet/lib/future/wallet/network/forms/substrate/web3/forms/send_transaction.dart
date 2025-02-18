import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateSendTransactionForm
    extends SubstrateWeb3Form<Web3SubstrateSendTransaction> {
  Web3SubstrateSendTransactionForm(this.request);
  @override
  Web3SubstrateRequest<Map<String, dynamic>, Web3SubstrateSendTransaction>
      request;
}
