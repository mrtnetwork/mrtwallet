import 'package:mrt_wallet/future/wallet/network/forms/sui/forms/core/sui.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';

class Web3SuiReadOnlyForm<PARAMS extends Web3SuiRequestParam>
    extends SuiWeb3Form<PARAMS> {
  Web3SuiReadOnlyForm({required this.request});

  @override
  Web3SuiRequest<dynamic, PARAMS> request;
}
