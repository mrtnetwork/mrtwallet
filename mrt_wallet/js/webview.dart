import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/js_wallet.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("#OnBackgroundListener_")
external set OnContentListener(JSFunction? f);

void main(List<String> args) async {
  if (mrtNull == null) {
    mrt = MRTWallet(JSObject());
  }
  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }

  final completer = Completer<JSWebviewWallet>();
  bool onActivation(JSWalletEvent data) {
    final walletEvent = data.toEvent();
    if (walletEvent == null || walletEvent.clientId != mrt.clientId) {
      return false;
    }
    switch (walletEvent.type) {
      case WalletEventTypes.exception:
        final message =
            Web3ExceptionMessage.deserialize(bytes: walletEvent.data);
        completer.completeError(message.toWalletError());
        return false;
      case WalletEventTypes.activation:
        final target = JSWebviewTraget.fromName(walletEvent.additional);
        if (target == null) {
          return false;
        }
        final wallet = JSWebviewWallet.initialize(
          request: walletEvent,
          clientId: walletEvent.clientId,
          target: target,
        );
        completer.complete(wallet);
        return true;
      default:
        return false;
    }
  }

  mrt.onMrtMessage = onActivation.toJS;
  await completer.future;
}
