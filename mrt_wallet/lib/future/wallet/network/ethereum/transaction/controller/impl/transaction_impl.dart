import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';

abstract class EthTransactionImpl extends StateController {
  EthTransactionImpl({required this.walletProvider, required this.account});
  WalletProvider walletProvider;
  final EthereumChain account;
  WalletEthereumNetwork get network => account.network;
  EthereumClient get apiProvider => account.provider()!;
  IEthAddress get address => account.address;
}
