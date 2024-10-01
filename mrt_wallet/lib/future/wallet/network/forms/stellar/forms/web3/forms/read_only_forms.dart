import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';

class Web3StellarReadOnlyForm<PARAMS extends Web3StellarRequestParam>
    extends StellarWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3StellarReadOnlyForm({required this.request});

  @override
  Web3StellarRequest<dynamic, PARAMS> request;
}
