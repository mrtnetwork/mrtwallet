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

abstract class SolanaTransactionForm extends TransactionForm {
  BigInt get transferValue;
  SolanaTransactionType get mode;
  SolanaChain? _account;
  ISolanaAddress? _address;
  SolanaChain get account => _account!;
  ISolanaAddress get address => _address!;
  DynamicVoid? onStimateChanged;
  SolanaClient? _apiProvider;
  SolanaClient? get provider => _apiProvider;

  @override
  String? validateError({ISolanaAddress? account});

  void initForm({SolanaChain? account, ISolanaAddress? address}) {
    _account = account;
    _address = address;
    _apiProvider = account?.clientNullable;
  }

  Future<List<TransactionInstruction>> instructions(SolAddress owner);
  @override
  void close() {
    _account = null;
    _address = null;
    _apiProvider = null;
    super.close();
  }
}

abstract class SolanaWeb3Form<PARAMS extends Web3SolanaRequestParam>
    extends Web3Form<SolAddress, SolanaChain, Web3SolanaChainAccount,
        Web3SolanaChain, PARAMS> {
  @override
  abstract final Web3SolanaRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  SolanaChain? _account;
  ISolanaAddress? _address;
  SolanaChain get account => _account!;
  ISolanaAddress get address => _address!;

  Future<void> initForm(
      {required SolanaChain account, ISolanaAddress? address}) async {
    _account = account;
    _address = address;
  }
}
