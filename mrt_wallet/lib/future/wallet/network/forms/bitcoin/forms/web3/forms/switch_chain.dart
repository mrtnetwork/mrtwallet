import 'package:mrt_wallet/future/wallet/network/forms/bitcoin/forms/core/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';

class Web3BitcoinSwitchBitcoinChain extends BitcoinWeb3Form {
  final BitcoinChain newChain;
  Web3BitcoinSwitchBitcoinChain(
      {required this.request, required this.newChain});

  @override
  @override
  final Web3BitcoinRequest<dynamic, Web3BitcoinRequestParam> request;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(response: true);
  }
}
