import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3StellarImpl<RESPONSE,
        T extends Web3StellarRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3StellarRequest>
    with Web3NetworkRequestControllerState<Web3StellarRequest> {
  Web3StellarImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final StellarChain account;
  WalletStellarNetwork get network => account.network;
  StellarClient get apiProvider => account.client;

  final Web3StellarRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  StellarWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3StellarRequestMethods.signMessage:
        return Web3StellarSignMessageForm<T>(request: request)
            as StellarWeb3Form<T>;

      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm liveRequest =
      LiveTransactionForm(validator: _buildForm());
  StellarWeb3Form<T> get form => liveRequest.value;
  @override
  Web3StellarRequest<RESPONSE, T> get web3Request => request;
}
