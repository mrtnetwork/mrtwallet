import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';

class Web3TronSwitchTronChain extends TronWeb3Form {
  final TronChain newChain;
  Web3TronSwitchTronChain({required this.request, required this.newChain});

  @override
  @override
  final Web3TronRequest<dynamic, Web3TronRequestParam> request;

  @override
  OnChangeForm? onChanged;

  @override
  String get name => request.params.method.name;

  @override
  void confirmRequest({Object? response}) {
    super.confirmRequest(
        response:
            newChain.network.tronNetworkType.genesisBlockNumber.toRadix16);
  }
}
