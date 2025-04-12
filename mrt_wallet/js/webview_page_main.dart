import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/js_wallet.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

void postToWallet(
    {required JSWorkerWalletData data, required JSWebviewTraget target}) {
  if (target.isMacos) {
    jsWindow.webkit.messageHandlers.mrt.postMessage(data.toJson().jsify());
    return;
  }
  mrt.onMrtJsRequest(data.clientId, data.data, data.requestId, data.type);
}

void main(List<String> args) async {
  final pageController = JSPageController.setup();
  if (mrtNull == null) {
    mrt = MRTWallet(JSObject());
  }

  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }

  final workerCompleter = Completer<(JSWebviewWallet, JSWebviewTraget)>();
  bool onActivation(JSWalletEvent data) {
    final walletEvent = data.toEvent();
    if (walletEvent == null || walletEvent.clientId != mrt.clientId) {
      return false;
    }
    if (walletEvent.type == WalletEventTypes.exception) {
      workerCompleter.completeError(
          JSWalletError(message: String.fromCharCodes(walletEvent.data)));
      return false;
    }
    final target = JSWebviewTraget.fromName(walletEvent.platform);
    if (target == null) return false;
    final wallet = JSWebviewWallet.initialize(
        request: walletEvent,
        clientId: walletEvent.clientId,
        isWorker: false,
        target: JSWebviewTraget.fromName(walletEvent.platform)!);
    workerCompleter.complete((wallet, target));
    return true;
  }

  mrt.onMrtMessage = onActivation.toJS;
  final activation = await workerCompleter.future;
  pageController.initClients(mrt.clientId);
  activation.$1.initClients();
}
