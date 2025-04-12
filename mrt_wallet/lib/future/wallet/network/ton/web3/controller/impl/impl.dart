import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/ton.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3TonImpl<RESPONSE, T extends Web3TonRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3TonRequest>
    with Web3NetworkRequestControllerState<Web3TonRequest> {
  Web3TonImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final TheOpenNetworkChain account;
  WalletTonNetwork get network => account.network;
  TonClient get apiProvider => account.client;
  ITonAddress get address => request.accountPermission()!;

  final Web3TonRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  TonWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3TonRequestMethods.signMessage:
        return Web3TonSignMessageForm<T>(request: request) as TonWeb3Form<T>;
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        return Web3TonSendTransactionForm(
            request: request as Web3TonRequest<Web3TonSendTransactionResponse,
                Web3TonSendTransaction>) as TonWeb3Form<T>;
      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm liveRequest =
      LiveTransactionForm(validator: _buildForm());
  TonWeb3Form<T> get form => liveRequest.value;
  @override
  Web3TonRequest<RESPONSE, T> get web3Request => request;
}
