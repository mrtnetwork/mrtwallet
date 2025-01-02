import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'js_wallet/js_wallet.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

@JS("#OnBackgroundListener_")
external set OnContentListener(JSFunction? f);

@JS("workerListener_")
external set workerListener(JSFunction? f);
@JS("workerListener_")
external JSFunction get workerListener;

@JS("errorListener_")
external set onWorkerErrorListener(JSFunction? f);
@JS("errorListener_")
external JSFunction get onWorkerErrorListener;
@JS("encodeURIComponent")
external String encodeURIComponent(String uriComponent);

void postToWallet(
    {required JSWorkerWalletData data, required JSWebviewTraget target}) {
  if (target.isMacos) {
    jsWindow.webkit.messageHandlers.mrt.postMessage(data.toJson().jsify());
    return;
  }
  mrt.onMrtJsRequest(data.clientId, data.data, data.requestId, data.type);
}

void main(List<String> args) async {
  if (mrtNull == null) {
    mrt = MRTWallet(JSObject());
  }

  final applicationId =
      Web3APPAuthentication.toApplicationId(jsWindow.location.origin);
  if (applicationId == null) {
    throw Web3RequestExceptionConst.invalidHost;
  }

  final workerCompleter = Completer<(Worker, JSWebviewTraget)>();
  bool onActivation(JSWalletEvent data) {
    final walletEvent = data.toEvent();
    if (walletEvent == null || walletEvent.clientId != mrt.clientId) {
      return false;
    }
    final target = JSWebviewTraget.fromName(walletEvent.platform);
    if (target == null) return false;

    final workerModule = data.additional!;
    final script = encodeURIComponent(workerModule);
    final worker = Worker('data:text/javascript,$script',
        WorkerOptions(type: "module", name: 'js'));
    onWorkerErrorListener = (MessageEvent event) {}.toJS;
    void onEvent(MessageEvent event) {
      final workerEvent = event.data as JSWorkerEvent;
      switch (workerEvent.eventType) {
        case JSWorkerType.ready:
          data.additional = null;
          worker.postMessage(data);
          break;
        case JSWorkerType.active:
          workerCompleter.complete((worker, target));
          worker.removeEventListener("error", onWorkerErrorListener);
          worker.removeEventListener("message", workerListener);
          onWorkerErrorListener = null;
          workerListener = null;
          postToWallet(
              data: JSWorkerWalletData(
                  clientId: mrt.clientId,
                  requestId: '',
                  data: '',
                  type: WalletEventTypes.activation.name),
              target: target);
          break;
        case JSWorkerType.error:
          final error = workerEvent.data as JSWalletError;
          worker.terminate();
          workerCompleter.completeError(error);
          postToWallet(
              data: JSWorkerWalletData(
                  clientId: mrt.clientId,
                  requestId: data.requestId!,
                  data: error.message ?? '',
                  type: WalletEventTypes.exception.name),
              target: target);
          break;
        case JSWorkerType.client:
          break;
        default:
          throw UnimplementedError();
      }
    }

    workerListener = onEvent.toJS;
    worker.addEventListener("error", onWorkerErrorListener);
    worker.addEventListener("message", workerListener);
    return true;
  }

  mrt.onMrtMessage = onActivation.toJS;
  final activation = await workerCompleter.future;

  final worker = activation.$1;
  final target = activation.$2;

  final pageController =
      JSWithWorkerPageController.setup(clientId: mrt.clientId, worker: worker);
  mrt.onMrtMessage = null;

  bool onWalletEvent(JSWalletEvent jsRequest) {
    worker
        .postMessage(JSWorkerEvent(type: JSWorkerType.wallet, data: jsRequest));
    return true;
  }

  void onWorkerWalletEvent(MessageEvent event) {
    final workerEvent = event.data as JSWorkerEvent;
    switch (workerEvent.eventType) {
      case JSWorkerType.wallet:
        final data = workerEvent.data as JSWorkerWalletData;
        postToWallet(data: data, target: target);
        break;
      case JSWorkerType.client:
        final data = workerEvent.data as WalletMessage;
        pageController.onWalletEvent(data);
        break;
      default:
    }
  }

  onWorkerErrorListener = (MessageEvent event) {}.toJS;
  workerListener = onWorkerWalletEvent.toJS;
  worker.addEventListener("error", onWorkerErrorListener);
  worker.addEventListener("message", workerListener);
  mrt.onMrtMessage = onWalletEvent.toJS;
}
