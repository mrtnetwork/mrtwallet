import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3CosmosImpl<RESPONSE,
        T extends Web3CosmosRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3CosmosRequest>
    with Web3NetworkRequestControllerState<Web3CosmosRequest> {
  Web3CosmosImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final CosmosChain account;
  WalletCosmosNetwork get network => account.network;
  CosmosClient get apiProvider => account.client;
  ICosmosAddress get address => request.accountPermission()!;
  final Web3CosmosRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  @override
  Web3CosmosRequest<RESPONSE, T> get web3Request => request;
}
