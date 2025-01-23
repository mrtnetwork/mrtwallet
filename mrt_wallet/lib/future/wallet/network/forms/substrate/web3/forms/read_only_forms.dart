import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';

class Web3SubstrateReadOnlyForm<PARAMS extends Web3SubstrateRequestParam>
    extends SubstrateWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3SubstrateReadOnlyForm({required this.request});

  @override
  Web3SubstrateRequest<dynamic, PARAMS> request;
}
