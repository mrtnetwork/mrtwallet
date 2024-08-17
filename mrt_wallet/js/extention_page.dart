import 'dart:async';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'js_wallet/models/models.dart';
import 'js_wallet/page/networks/eth.dart';
import 'dart:js_interop';

@JS("handler")
extension type ProxyHandler._(JSAny _) {
  external ProxyHandler({required JSFunction set, required JSFunction get});
}

@JS("Proxy")
extension type MRTProxy._(JSObject _) implements MRTWallet, ProxyHandler {
  external factory MRTProxy(MRTWallet object, ProxyHandler handler);
}
void main(List<String> args) async {
  final completer = Completer<String>();

  void onActivation(CustomEvent data) {
    final idBytes = data.detailBytes();
    if (idBytes == null) {
      return;
    }
    final event = WalletResponse.deserialize(bytes: data.detailBytes())
        .cast<WalletRequestResponse>();
    if (event.status == WalletRequestResponseType.failed) {
      final walletError =
          MRTWalletError.fromJson(message: event.data as Map<String, dynamic>);
      completer.completeError(walletError);
      return;
    }
    completer.complete(event.data as String);
  }

  jsWindow.addEventListener("MRT_ACTIVATION", onActivation.toJS);
  final future = completer.future;
  future.then((e) {
    jsWindow.removeEventListener("MRT_ACTIVATION", onActivation.toJS);
    EthereumJsController.setup(e);
  });
}
