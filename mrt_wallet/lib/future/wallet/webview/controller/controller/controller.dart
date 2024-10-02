import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/controller/wallet/ui_wallet.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_controller.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_handler.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';

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
  final Cancelable _cancelable = Cancelable();
  final _lock = SynchronizedLock();
  @override
  UIWallet get walletCore => walletProvider.wallet;
  WebViewStateController(this.walletProvider);

  Future<bool> _postEvent(WalletEvent event) async {
    try {
      final result = await _loadScript<bool>(
          script: "MRT.onMrtMessage(${StringUtils.fromJson(event.toJson())})",
          viewType: event.clientId);
      return result!;
    } catch (e) {
      return false;
    }
  }

  Future<T?> _loadScript<T>(
      {required String viewType, required String script}) async {
    final result =
        await webViewController.loadScript(viewType: viewType, script: script);

    if (result == null) return null;
    return StringUtils.tryToJson(result as String);
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

  Future<bool> _mrtInitialized(String viewType) async {
    final result =
        await _loadScript(script: "MRT.ethereum", viewType: viewType);
    return result != null;
  }

  final Live<MRTScriptWalletStatus> _web3Status =
      Live(MRTScriptWalletStatus.progress);
  Live<MRTScriptWalletStatus> get web3Status => _web3Status;
  Future<MRTScriptWalletStatus> _activeScript(WebViewEvent event) async {
    return await _lock.synchronized(() async {
      try {
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
        final tronWeb =
            await PlatformUtils.loadAssetText(APPConst.assetsTronWeb);
        await _loadScript(viewType: event.viewId, script: tronWeb);
        final solanaJs = await PlatformUtils.loadAssetText(APPConst.bnJs);
        await _loadScript(viewType: event.viewId, script: solanaJs);
        String script;
        if (kDebugMode) {
          if (PlatformInterface.appPlatform == AppPlatform.android) {
            script =
                (await HttpUtils.get<String>("http://10.0.2.2:3000/webview"))
                    .result;
          } else {
            script =
                (await HttpUtils.get<String>("http://localhost:3000/webview"))
                    .result;
          }
        } else {
          script =
              await PlatformUtils.loadAssetText(APPConst.assetWebviewScript);
        }
        await _loadScript(viewType: event.viewId, script: script);

        final responseEvent =
            await getPageAuthenticated(clientId: auth.viewType, info: client);
        final result = await _postEvent(responseEvent);
        if (result) {
          return MRTScriptWalletStatus.active;
        }
        return MRTScriptWalletStatus.failed;
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  Future<void> switchTab(WebViewController controller) async {
    await super.switchTab(controller);
    final viewType = this.viewType;
    if (viewType == null) return;
    final inited = await _mrtInitialized(viewType);
    if (!inited) reload();
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
        request.completeError();
      }
    } on Web3RejectException {
      return;
    }
  }

  @override
  Future<void> sendToClient(WalletEvent event) async {
    await _postEvent(event);
  }

  @override
  void close() {
    super.close();
    webViewController.removeListener(this);
    _web3Status.dispose();
  }
}
