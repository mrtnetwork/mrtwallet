import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'js_wallet/constant/constant.dart';
import 'js_wallet/js_wallet.dart';
import 'dart:js_interop';

void main(List<String> args) async {
  final pageController = JSPageController.setup();
  mrt = MRTWallet(JSObject());
  bool inited = false;
  void onActivation(CustomEvent data) {
    if (inited) return;
    final event = (data.detail as WalletMessage).data as WalletMessageResponse;
    if (event.statusType == JSWalletResponseType.failed) {
      final walletError = JSWalletError.fromJson(message: event.asMap());
      pageController.disable(walletError);
      return;
    }
    inited = true;
    jsWindow.addEventListener(
        JSWalletConstant.activationEventName, onActivation.toJS);
    pageController.initClients(event.asString());
  }

  jsWindow.addEventListener(
      JSWalletConstant.activationEventName, onActivation.toJS);
}
