import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

abstract class Web3BitcoinImpl<RESPONSE,
        T extends Web3BitcoinRequestParam<RESPONSE>>
    extends Web3StateContoller<Web3BitcoinRequest>
    with Web3NetworkRequestControllerState<Web3BitcoinRequest> {
  Web3BitcoinImpl(
      {required this.walletProvider,
      required this.account,
      required this.request});
  final WalletProvider walletProvider;
  final BitcoinChain account;
  WalletBitcoinNetwork get network => account.network;
  BitcoinClient get apiProvider => account.client;
  IBitcoinAddress get address => request.accountPermission()!;
  final Web3BitcoinRequest<RESPONSE, T> request;
  bool get needPermission => request.needPermission;

  @override
  Web3BitcoinRequest<RESPONSE, T> get web3Request => request;
}
