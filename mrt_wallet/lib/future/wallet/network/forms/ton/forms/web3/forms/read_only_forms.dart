import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';

class Web3TonReadOnlyForm<PARAMS extends Web3TonRequestParam>
    extends TonWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3TonReadOnlyForm({required this.request});

  @override
  Web3TonRequest<dynamic, PARAMS> request;
}
