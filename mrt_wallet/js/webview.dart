import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'js_wallet/js_wallet.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("#OnBackgroundListener_")
external set OnContentListener(JSFunction? f);

@JS("postMessage")
external void postMessage(JSWorkerEvent data);
@JS("onmessage")
external set onMessage(JSFunction _);

void main(List<String> args) async {
  final walletCompleter = Completer<(JSWorkerEvent, JSWebviewWallet?)>();

  void onData(MessageEvent event) {
    final data = event.data as JSWalletEvent;
    final walletEvent = data.toEvent();
    switch (walletEvent!.type) {
      case WalletEventTypes.exception:
        final message =
            Web3ExceptionMessage.deserialize(bytes: walletEvent.data);
        final error = JSWorkerEvent(
            data: message.toWalletError(), type: JSWorkerType.error);
        walletCompleter.complete((error, null));
        break;
      case WalletEventTypes.activation:
        final activeEvent = JSWorkerEvent(type: JSWorkerType.active);
        final wallet = JSWebviewWallet.initialize(
            request: walletEvent,
            clientId: walletEvent.clientId,
            target: JSWebviewTraget.fromName(walletEvent.platform)!);
        walletCompleter.complete((activeEvent, wallet));
        break;
      default:
        break;
    }
  }

  onMessage = onData.toJS;
  postMessage(JSWorkerEvent(type: JSWorkerType.ready));
  final event = await walletCompleter.future;
  postMessage(event.$1);
  final wallet = event.$2;
  if (wallet != null) {
    wallet.initClients();
  }
}
