import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

enum SolanaTransactionType {
  native,
  spl,
  createAssociatedTokenAccount,
  createAccount,
  initializeMint,
  mintTo;
}

abstract class SolanaTransactionForm implements TransactionForm {
  BigInt get transferValue;
  SolanaTransactionType get mode;
  @override
  String? validateError({ISolanaAddress? account});
  DynamicVoid? onStimateChanged;
  SolanaClient? _apiProvider;
  SolanaClient? get provider => _apiProvider;
  void setProvider(SolanaClient? rpc) {
    _apiProvider = rpc;
  }

  Future<List<TransactionInstruction>> instructions(SolAddress owner);
}

abstract class SolanaWeb3Form<PARAMS extends Web3SolanaRequestParam>
    implements
        Web3Form<SolAddress, SolanaChain, Web3SolanaChainAccount,
            Web3SolanaChain, PARAMS> {
  @override
  abstract final Web3SolanaRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  ObjectVoid? onCompeleteForm;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompeleteForm?.call(response);
  }
}
