import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/ethereum.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3EthereumImpl<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>> extends EthTransactionImpl
    with Web3RequestControllerState {
  Web3EthereumImpl({required super.walletProvider, required this.request})
      : super(account: request.chain);

  final Web3EthereumRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;
  @override
  IEthAddress get address => request.accountPermission()!;

  EthereumWeb3Form<T> _buildForm() {
    switch (request.params.method) {
      case Web3EthereumRequestMethods.requestAccounts:
        final ethChains = walletProvider.wallet.getChains<EthereumChain>();
        return EthereumRequestAccountForm(request: request, chains: ethChains)
            as EthereumWeb3Form<T>;
      case Web3EthereumRequestMethods.switchEthereumChain:
        final switchChainRequest = request.params as Web3EthreumSwitchChain;
        final ethChains = walletProvider.wallet
            .getChains<EthereumChain>()
            .firstWhere((e) => e.chainId == switchChainRequest.chainId);
        return Web3EthereumSwitchEthereumChain(
            request: request, newChain: ethChains) as EthereumWeb3Form<T>;
      default:
        return Web3EthereumReadOnlyForm<T>(request: request);
    }
  }

  late final LiveTransactionForm liveRequest =
      LiveTransactionForm(validator: _buildForm());
  EthereumWeb3Form<T> get form => liveRequest.value;
  @override
  Web3Request get web3Request => request;
}
