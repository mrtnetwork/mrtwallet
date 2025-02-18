import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';

class Web3SuiSwitchSuiChain extends SuiWeb3Form {
  final SuiChain newChain;
  Web3SuiSwitchSuiChain({required this.request, required this.newChain});

  @override
  @override
  final Web3SuiRequest<dynamic, Web3SuiRequestParam> request;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(response: true);
  }
}
