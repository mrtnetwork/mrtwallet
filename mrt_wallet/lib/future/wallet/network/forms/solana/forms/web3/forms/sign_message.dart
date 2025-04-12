import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3SolanaSignMessageForm extends SolanaWeb3Form<Web3SolanaSignMessage> {
  Web3SolanaSignMessageForm({required this.request});

  @override
  Web3SolanaRequest<List<Web3SolanaSignMessageResponse>, Web3SolanaSignMessage>
      request;
  List<Web3SolanaSignMessageItemView> _messages = [];
  List<Web3SolanaSignMessageItemView> get messages => _messages;
  Future<void> signMessage(FuncFutureNullableBoold confirm) async {
    final accept = await confirm();
    if (accept != true) return;
    onCompleteForm?.call(request.params.messages);
  }

  @override
  Future<void> initForm(
      {required SolanaChain account, ISolanaAddress? address}) async {
    await super.initForm(account: account, address: address);
    List<Web3SolanaSignMessageItemView> messages = [];
    for (final i in request.params.messages) {
      final msg = Web3SolanaSignMessageItemView(
          address: request.currentPermission!
              .getAccountPermission(account: i.account, chain: account),
          method: request.params.method,
          params: i);
      messages.add(msg);
    }
    _messages = messages.imutable;
  }
}

class Web3SolanaSignMessageItemView {
  final ISolanaAddress address;
  final Web3SolanaSignParams params;
  const Web3SolanaSignMessageItemView(
      {required this.address, required this.params, required this.method});
  final Web3SolanaRequestMethods method;
  bool get isSignIn => method == Web3SolanaRequestMethods.signIn;
}
