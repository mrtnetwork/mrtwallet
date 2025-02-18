import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';

class Web3AptosSwitchAptosChain extends AptosWeb3Form {
  final AptosChain newChain;
  Web3AptosSwitchAptosChain({required this.request, required this.newChain});

  @override
  @override
  final Web3AptosRequest<dynamic, Web3AptosRequestParam> request;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(response: true);
  }
}
