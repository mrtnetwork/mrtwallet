import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ethereum/client/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3EthereumImpl<RESPONSE,
        T extends Web3EthereumRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3EthereumRequest>
    with Web3NetworkRequestControllerState<Web3EthereumRequest> {
  Web3EthereumImpl({required this.walletProvider, required this.request});
  WalletProvider walletProvider;
  WalletEthereumNetwork get network => account.network;
  EthereumClient get apiProvider => account.client;
  EthereumChain get account => request.chain;
  final Web3EthereumRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;
  IEthAddress get address => request.accountPermission()!;

  @override
  Web3EthereumRequest<RESPONSE, T> get web3Request => request;
}
