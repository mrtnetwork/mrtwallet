import 'package:mrt_wallet/future/wallet/network/forms/aptos/forms/core/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';

class Web3AptosReadOnlyForm<PARAMS extends Web3AptosRequestParam>
    extends AptosWeb3Form<PARAMS> {
  Web3AptosReadOnlyForm({required this.request});

  @override
  Web3AptosRequest<dynamic, PARAMS> request;
}
