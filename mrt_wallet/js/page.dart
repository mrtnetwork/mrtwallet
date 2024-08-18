import 'dart:async';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'js_wallet/constant/constant.dart';
import 'js_wallet/js_wallet.dart';
import 'dart:js_interop';

void main(List<String> args) async {
  mrt = MRTWallet(JSObject());
  final completer = Completer<String>();

  void onActivation(CustomEvent data) {
    final idBytes = data.detailBytes();
    if (idBytes == null) {
      return;
    }
    final event = JSWalletMessage.deserialize(bytes: data.detailBytes())
        .cast<JSWalletMessageResponse>();
    if (event.status == JSWalletResponseType.failed) {
      final walletError =
          JSWalletError.fromJson(message: event.data as Map<String, dynamic>);
      completer.completeError(walletError);
      return;
    }
    completer.complete(event.data as String);
  }

  jsWindow.addEventListener(
      JSWalletConstant.activationEventName, onActivation.toJS);
  final future = await completer.future;
  jsWindow.removeEventListener(
      JSWalletConstant.activationEventName, onActivation.toJS);

  EthereumJsController.setup(future);
}
