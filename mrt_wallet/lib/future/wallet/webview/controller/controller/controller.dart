import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/controller/wallet/ui_wallet.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_handler.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/wroker/impl/worker_impl.dart';

enum MRTScriptWalletStatus {
  progress,
  active,
  failed,
  block;

  bool get inProgress => this == progress;
}

class WebViewStateController extends StateController
    with
        CryptoWokerImpl,
        Web3RequestControllerImpl,
        WebViewListener,
        WebViewTabImpl {
  final WalletProvider walletProvider;
  // Web3APPAuthentication? _LastApplication;
  final Cancelable _cancelable = Cancelable();
  final _lock = SynchronizedLock();
  @override
  UIWallet get walletCore => walletProvider.wallet;
  WebViewStateController(this.walletProvider);

  Future<bool> _postEvent(WalletEvent event) async {
    try {
      final result = await _loadScript(
          script: "MRT.onMrtMessage(${StringUtils.fromJson(event.toJson())})",
          viewType: event.clientId);
      final toJson = StringUtils.toJson<bool>(result!);
      return toJson;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _loadScript<T>(
      {required String viewType, required String script}) async {
    final result =
        await webViewController.loadScript(viewType: viewType, script: script);
    return result as String?;
  }

  @override
  Future<Web3ClientInfo?> currentApllicationId() async {
    final last = lastEvent;
    if (last == null) return null;
    return createClientInfos(
        clientId: last.viewId,
        url: last.url,
        faviIcon: last.favicon,
        title: last.title);
  }

  @override
  Future<void> updatePermission(Web3APPAuthentication updatePermission) async {
    final message =
        (await walletCore.updateWeb3Application(updatePermission)).result;
    await _lock.synchronized(() async {
      final lastEvent = this.lastEvent;
      final lastEventUri = lastEvent?.url;
      if (lastEventUri != null) {
        final appLocationId =
            Web3APPAuthentication.toApplicationId(lastEventUri);

        if (appLocationId == updatePermission.applicationId) {
          final event = toResponseEvent(
              id: lastEvent!.viewId,
              type: WalletEventTypes.message,
              data: message.toCbor().encode());
          await _postEvent(event);
        }
      }
    });
  }

  final Live<MRTScriptWalletStatus> _web3Status =
      Live(MRTScriptWalletStatus.progress);
  Live<MRTScriptWalletStatus> get web3Status => _web3Status;
  Future<MRTScriptWalletStatus> _activeScript(WebViewEvent event) async {
    return await _lock.synchronized(() async {
      _cancelable.cancel();
      final applicationId =
          Web3APPAuthentication.toApplicationId(lastEvent?.url);
      onCloseClinet(applicationId);
      final auth = tabsAuthenticated[event.viewId];

      if (auth == null) return MRTScriptWalletStatus.failed;
      final client = await createClientInfos(
          clientId: event.viewId,
          url: event.url,
          title: event.title,
          faviIcon: event.favicon);
      final String script =
          (await HttpUtils.get<String>("http://10.0.2.2:3000/a")).result;
      await _loadScript(viewType: event.viewId, script: script);
      await webViewController
          .addJsInterface(viewType: event.viewId, name: "MRT")
          .catchError((e) {});
      final responseEvent =
          await getPageAuthenticated(clientId: auth.viewType, info: client);
      final result = await _postEvent(responseEvent);
      if (result) {
        return MRTScriptWalletStatus.active;
      }
      return MRTScriptWalletStatus.failed;
    });
  }

  @override
  void onPageStart(WebViewEvent event) async {
    super.onPageStart(event);
    _web3Status.value = MRTScriptWalletStatus.progress;
    _web3Status.value = await _activeScript(event);
  }

  @override
  void onPageRequest(WebViewEvent event) async {
    if (event.request == null) return;
    final client = await createClientInfos(
        clientId: event.viewId,
        url: event.url,
        faviIcon: event.favicon,
        title: event.title);
    if (client == null) {
      await _postEvent(toResponseEvent(
          id: event.viewId,
          type: WalletEventTypes.exception,
          data: Web3RequestExceptionConst.invalidHost
              .toResponseMessage()
              .toCbor()
              .encode(),
          requestId: event.request!.requestId));
      return;
    }

    final request = Web3RequestApplicationInformation(
        info: client, request: event.request!);

    onWalletEvent(request);
    try {
      final responseEvent = await request.onCompleteRequest;
      final bool result = await _postEvent(responseEvent);
      if (result) {
        request.completeSuccess();
      } else {
        request.completeError;
      }
    } on Web3RejectException {
      return;
    }
  }

  @override
  void close() {
    super.close();
    webViewController.removeListener(this);
    _web3Status.dispose();
  }

  @override
  Future<void> sendToClient(WalletEvent event) async {
    await _postEvent(event);
  }
}
