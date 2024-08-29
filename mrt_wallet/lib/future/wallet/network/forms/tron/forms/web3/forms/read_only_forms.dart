import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/tron.dart';

class Web3TronReadOnlyForm<PARAMS extends Web3TronRequestParam>
    extends TronWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3TronReadOnlyForm({required this.request});

  @override
  Web3TronRequest<dynamic, PARAMS> request;
}
