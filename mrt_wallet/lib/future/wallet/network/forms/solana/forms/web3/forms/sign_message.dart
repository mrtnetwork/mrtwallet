import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/params/core/request.dart';

class Web3SolanaSignMessageForm<PARAMS extends Web3SolanaRequestParam>
    extends SolanaWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3SolanaSignMessageForm({required this.request});

  @override
  Web3SolanaRequest<dynamic, PARAMS> request;

  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompeleteForm?.call(true);
  }
}
