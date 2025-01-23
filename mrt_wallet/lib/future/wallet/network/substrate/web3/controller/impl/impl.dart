import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3SubstrateImpl<RESPONSE,
        T extends Web3SubstrateRequestParam<RESPONSE>> extends StateController
    with Web3RequestControllerState {
  Web3SubstrateImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final SubstrateChain account;
  WalletSubstrateNetwork get network => account.network;
  SubstrateClient get apiProvider => account.client;
  ISubstrateAddress get address => request.accountPermission()!;

  final Web3SubstrateRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  SubstrateWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        final substrateChains =
            walletProvider.wallet.getChains<SubstrateChain>();
        return SubstrateRequestAccountForm(
            request: request, chains: substrateChains) as SubstrateWeb3Form<T>;
      case Web3SubstrateRequestMethods.signMessage:
        return Web3SubstrateSignMessageForm<T>(request: request)
            as SubstrateWeb3Form<T>;
      case Web3SubstrateRequestMethods.addSubstrateChain:
        final param = request.params.cast<Web3SubstrateAddNewChain>();
        final chain = walletProvider.wallet
            .getChains<SubstrateChain>()
            .firstWhereOrNull(
                (e) => e.network.genesisBlock == param.genesisHash);
        return Web3SubstrateAddNewChainForm(
            request: request.cast(), chain: chain) as SubstrateWeb3Form<T>;

      default:
        throw UnimplementedError();
    }
  }

  late final LiveTransactionForm liveRequest =
      LiveTransactionForm(validator: _buildForm());
  SubstrateWeb3Form<T> get form => liveRequest.value;
  @override
  Web3Request get web3Request => request;
}
