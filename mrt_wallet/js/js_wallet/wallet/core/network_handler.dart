import 'dart:js_interop';

import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

import '../../models/models/requests.dart';
import 'wallet.dart';

abstract class ChainWeb3State {
  static const requestTimeout = Duration(seconds: 1);
  ChainWeb3State({required this.state});

  final JSNetworkState state;
}

abstract class JSNetworkHandler<STATE extends ChainWeb3State> {
  JSNetworkHandler({required this.sendMessageToClient});
  final SynchronizedLock lock = SynchronizedLock();
  STATE get state;

  Future<Web3MessageCore> request(PageMessageRequest message);

  void event(PageMessageEvent event);

  void onRequestDone(PageMessageRequest message) {}

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
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    return WalletMessageResponse.success(response.result.jsify());
  }

  final SendMessageToClient sendMessageToClient;
  abstract final NetworkType networkType;
  Web3ResponseMessage buildResponse(Object? result) {
    return Web3ResponseMessage(result: result, network: networkType);
  }

  Future<void> initChain(Web3APPData authenticated);

  Future<Web3MessageCore> discoonect() async {
    return Web3DisconnectApplication(chain: networkType);
  }
}

enum JSNetworkState {
  init,
  disconnect,
  block;

  bool get isBlock => this == block;
  bool get isInit => this == init;
}
