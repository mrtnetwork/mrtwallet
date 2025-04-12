import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3AptosImpl<RESPONSE,
        T extends Web3AptosRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3AptosRequest>
    with Web3NetworkRequestControllerState<Web3AptosRequest> {
  Web3AptosImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final AptosChain account;
  WalletAptosNetwork get network => account.network;
  AptosClient get apiProvider => account.client;
  IAptosAddress get address => request.accountPermission()!;
  final Web3AptosRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  @override
  Web3AptosRequest<RESPONSE, T> get web3Request => request;
}
