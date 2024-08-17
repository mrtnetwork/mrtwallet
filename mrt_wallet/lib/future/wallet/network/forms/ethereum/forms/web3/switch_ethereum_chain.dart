import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/requests.dart';

class Web3EthereumSwitchEthereumChain extends EthereumWeb3Form {
  final EthereumChain newChain;
  Web3EthereumSwitchEthereumChain(
      {required this.request, required this.newChain});

  @override
  @override
  final Web3EthereumRequest<dynamic, Web3EthereumRequestParam> request;

  @override
  OnChangeForm? onChanged;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(response: newChain.chainId.toRadix16);
  }
}
