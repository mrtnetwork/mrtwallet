import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';

class Web3EthereumReadOnlyForm<PARAMS extends Web3EthereumRequestParam>
    extends EthereumWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3EthereumReadOnlyForm({required this.request});

  @override
  Web3EthereumRequest<dynamic, PARAMS> request;
}
