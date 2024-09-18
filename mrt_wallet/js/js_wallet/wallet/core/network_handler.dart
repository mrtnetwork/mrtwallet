import 'dart:js_interop';

import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
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
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUNT>,
    // MESSAGE extends PageMessage,
    STATE extends ChainWeb3State<NETWORKADDRESS, CHAIN, WEB3CHAIN>> {
  JSNetworkHandler({required this.sendMessageToClient});
  final SynchronizedLock lock = SynchronizedLock();
  STATE get state;

  Future<Web3MessageCore> request(PageMessageRequest message);

  void event(PageMessageEvent event);

  void onRequestDone(PageMessageRequest message);

  WalletMessageResponse finilizeError(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3ExceptionMessage error}) {
    return WalletMessageResponse.fail(error.toJson().jsify());
  }

  WalletMessageResponse finilizeResponse(
      {required PageMessageRequest message,
      required Web3ResponseMessage response}) {
    return WalletMessageResponse.success(response.result.jsify());
  }

  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams params,
      required Web3WalletResponseMessage response}) {
    return WalletMessageResponse.success(response.result.jsify());
  }

  final SendMessageToClient sendMessageToClient;
  abstract final NetworkType networkType;
  Web3ResponseMessage buildResponse(Object? result) {
    return Web3ResponseMessage(result: result, network: networkType);
  }

  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler});
}

enum JSNetworkState {
  init,
  disconnect,
  block;

  bool get isBlock => this == block;
  bool get isInit => this == init;
}
