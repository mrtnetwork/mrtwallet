import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

import '../../models/models/requests.dart';
import 'wallet.dart';

typedef WEB3CHAINSTATE<NETWORKADDRESS> = ChainWeb3State<NETWORKADDRESS,
    APPCHAINNETWORK<NETWORKADDRESS>, Web3ChainNetwork<NETWORKADDRESS>>;

abstract class ChainWeb3State<
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    WEB3CHAIN extends Web3ChainNetwork<NETWORKADDRESS>> {
  static const requestTimeout = Duration(seconds: 1);

  ChainWeb3State({
    required this.permission,
    required List<CHAIN> chains,
    required this.state,
    required List<String> permissionAccounts,
  })  : permissionAccounts = permissionAccounts.imutable,
        chains = chains.imutable;
  final WEB3CHAIN? permission;
  final List<CHAIN> chains;
  final List<String> permissionAccounts;
  final JSNetworkState state;
}

abstract class JSNetworkHandler<
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    WEB3CHAIN extends Web3ChainNetwork<NETWORKADDRESS>,
    MESSAGE extends PageMessage,
    STATE extends ChainWeb3State<NETWORKADDRESS, CHAIN, WEB3CHAIN>> {
  JSNetworkHandler({required this.sendMessageToClient});
  final SynchronizedLock lock = SynchronizedLock();
  STATE get state;

  Future<Web3MessageCore> request(MESSAGE message);
  Web3MessageCore finilize(MESSAGE request, Web3MessageCore response);

  void onRequestDone(MESSAGE message);
  final SendMessageToClient sendMessageToClient;
  abstract final NetworkType networkType;
  Web3ResponseMessage buildResponse(Object? result) {
    return Web3ResponseMessage(result: result, network: networkType);
  }
}

enum JSNetworkState {
  init,
  disconnect,
  block;

  bool get isBlock => this == block;
  bool get isInit => this == init;
}
