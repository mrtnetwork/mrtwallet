import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';

class Web3TonSignMessageForm<PARAMS extends Web3TonRequestParam>
    extends TonWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3TonSignMessageForm({required this.request});

  @override
  Web3TonRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompeleteForm?.call(true);
  }
}
