import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3SuiImpl<RESPONSE, T extends Web3SuiRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3SuiRequest>
    with Web3NetworkRequestControllerState<Web3SuiRequest> {
  Web3SuiImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final SuiChain account;
  WalletSuiNetwork get network => account.network;
  SuiClient get apiProvider => account.client;
  ISuiAddress get address => request.accountPermission()!;
  final Web3SuiRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  @override
  Web3SuiRequest<RESPONSE, T> get web3Request => request;
}
