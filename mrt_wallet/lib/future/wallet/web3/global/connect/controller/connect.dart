import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3GlobalRequestConnectStateController
    extends Web3StateContoller<Web3GlobalRequest>
    with Web3GlobalRequestControllerState {
  NetworkType? _network;
  NetworkType? get network => _network;
  @override
  final Web3GlobalRequest web3Request;
  Web3GlobalRequestConnectStateController(this.web3Request);

  Future<void> onUpdateApplication(List<NetworkType> networks) async {
    progressKey.response();
    web3Request.completeResponse(networks);
  }

  @override
  Future<void> initWeb3() async {
    final param = web3Request.params.cast<Web3ConnectApplication>();
    _network = param.chain;
    progressKey.idle();
  }
}
