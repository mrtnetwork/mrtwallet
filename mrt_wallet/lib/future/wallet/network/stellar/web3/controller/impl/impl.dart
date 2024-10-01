import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3StellarImpl<RESPONSE,
        T extends Web3StellarRequestParam<RESPONSE>> extends StateController
    with Web3RequestControllerState {
  Web3StellarImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final StellarChain account;
  WalletStellarNetwork get network => account.network;
  StellarClient get apiProvider => account.provider()!;
  IStellarAddress get address => request.accountPermission()!;

  final Web3StellarRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  StellarWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3StellarRequestMethods.requestAccounts:
        final stellarChains = walletProvider.wallet.getChains<StellarChain>();
        return StellarRequestAccountForm(
            request: request, chains: stellarChains) as StellarWeb3Form<T>;
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
  Web3Request get web3Request => request;
}
