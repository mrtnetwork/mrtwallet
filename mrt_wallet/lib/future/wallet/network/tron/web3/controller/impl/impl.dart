import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/networks/tron/client/tron.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3TronImpl<RESPONSE, T extends Web3TronRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3TronRequest>
    with Web3NetworkRequestControllerState<Web3TronRequest> {
  Web3TronImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final TronChain account;
  WalletTronNetwork get network => account.network;
  TronClient get apiProvider => account.client;
  ITronAddress get address => request.accountPermission()!;

  final Web3TronRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  @override
  Web3TronRequest<RESPONSE, T> get web3Request => request;
}
