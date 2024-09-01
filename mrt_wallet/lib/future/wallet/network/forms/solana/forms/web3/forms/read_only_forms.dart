import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';

class Web3SolanaReadOnlyForm<PARAMS extends Web3SolanaRequestParam>
    extends SolanaWeb3Form<PARAMS> {
  @override
  OnChangeForm? onChanged;

  Web3SolanaReadOnlyForm({required this.request});

  @override
  Web3SolanaRequest<dynamic, PARAMS> request;
}
