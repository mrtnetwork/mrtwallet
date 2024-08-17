import 'package:mrt_wallet/wallet/web3/core/core.dart';

class WalletWeb3Request {
  final Web3RequestParams message;
  final Web3RequestApplicationInformation info;
  final Web3APPAuthentication appAuthenticated;
  WalletWeb3Request(
      {required this.info,
      required this.appAuthenticated,
      required this.message});
}
