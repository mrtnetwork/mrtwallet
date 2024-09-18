import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/permission.dart';
import 'params.dart';

abstract class Web3PermissionRequest<
        NETWORKADDRESS,
        CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
        CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
        WEB3ChAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUNT>>
    implements
        Web3RequestParams<WEB3ChAIN, NETWORKADDRESS, CHAIN, CHAINACCOUNT,
            WEB3ChAIN> {
  @override
  bool get isPermissionRequest => true;
}
