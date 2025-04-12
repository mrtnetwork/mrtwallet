import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3SolanaImpl<RESPONSE,
        T extends Web3SolanaRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3SolanaRequest>
    with Web3NetworkRequestControllerState<Web3SolanaRequest> {
  Web3SolanaImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final SolanaChain account;
  WalletSolanaNetwork get network => account.network;
  SolanaClient get apiProvider => account.client;
  ISolanaAddress get address => request.accountPermission()!;

  final Web3SolanaRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  SolanaWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        return Web3SolanaSignMessageForm(request: request.cast())
            as SolanaWeb3Form<T>;
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
        return Web3SolanaSendTransactionForm(
            request: request as Web3SolanaRequest<List<Map<String, dynamic>>,
                Web3SolanaSendTransaction>) as SolanaWeb3Form<T>;
      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm liveRequest =
      LiveTransactionForm(validator: _buildForm());
  SolanaWeb3Form<T> get form => liveRequest.value;
  @override
  Web3SolanaRequest<RESPONSE, T> get web3Request => request;
}
