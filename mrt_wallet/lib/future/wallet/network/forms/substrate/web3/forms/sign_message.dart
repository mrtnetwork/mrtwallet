import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class Web3SubstrateSignMessageForm<PARAMS extends Web3SubstrateRequestParam>
    extends SubstrateWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3SubstrateSignMessageForm({required this.request});

  @override
  Web3SubstrateRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(true);
  }
}
