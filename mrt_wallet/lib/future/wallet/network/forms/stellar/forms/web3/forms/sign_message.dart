import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';

class Web3StellarSignMessageForm<PARAMS extends Web3StellarRequestParam>
    extends StellarWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3StellarSignMessageForm({required this.request});

  @override
  Web3StellarRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompeleteForm?.call(true);
  }
}
