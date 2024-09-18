import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_controller.dart';
import 'package:mrt_wallet/future/wallet/webview/view/native_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/repository/models/models/webview_repository.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';

class _WebViewStateControllerConst {
  static const int viewIdLength = 12;
  static const String googleSerchUrl = "https://www.google.com/search?q=";
  static const String interfaceName = "MRT";
  static const String debug = "http://10.0.2.2:3000/";
  static const String google = "https://google.com/";
}

enum WebViewTabPage {
  browser,
  tabs,
  history,
  bookmarks;
}

mixin WebViewTabImpl on StateController, CryptoWokerImpl, WebViewListener {
  bool _inited = false;
  bool get inited => _inited;
  String get _website {
    if (kDebugMode) {
      return _WebViewStateControllerConst.debug;
    }
    return _WebViewStateControllerConst.google;
  }

  late final FocusNode focusNode = FocusNode()
    ..addListener(_textFieldFocusNode);

  void _textFieldFocusNode() {
    if (!focusNode.hasFocus) {
      onSubmitTextField();
    }
  }

  final _tabLocker = SynchronizedLock();
  final PlatformWebView webViewController = PlatformInterface.instance.webView;
  final WebViewRepository _storage = WebViewRepository();
  final Map<String, WebViewController> tabsAuthenticated = {};
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> textField = GlobalKey();
  List<WebViewTab> get histories => _storage.histories;
  List<WebViewTab> get bookmarks => _storage.bookmarks;

  WebViewController get controller => tabsAuthenticated[_currentViewId]!;
  WebViewTab get tab => controller.tab.value;

  int get tabsLength => tabsAuthenticated.length;
  List<WebViewController> get controllers => tabsAuthenticated.values.toList();
  WebViewEvent? get lastEvent => _event;
  WebViewEvent? _event;
  final Live<double?> _progress = Live<double?>(null);
  final Live<bool> liveNotifier = Live<bool>(false);
  Live<double?> get progress => _progress;
  String? _currentViewId;
  @override
  String? get viewType => _currentViewId;
  WebViewTabPage _page = WebViewTabPage.browser;
  WebViewTabPage get page => _page;
  bool get inBrowser => _page == WebViewTabPage.browser;
  bool _inBokmark = false;
  bool get inBokmark => _inBokmark;

  void removeHistory(WebViewTab tab) async {
    _tabLocker.synchronized(() async {
      await _storage.removeHistory(tab);
      if (histories.isEmpty) {
        backToBorwser();
      }
    });
  }

  void openTabPage(WebViewTab tab) {
    textField.currentState?.updateText(tab.url);
    webViewController.openUrl(viewType: viewType!, url: tab.url);
    backToBorwser();
  }

  void clearHistory() {
    _tabLocker.synchronized(() async {
      await _storage.clearHistory();
    });
    backToBorwser();
  }

  void removeBookmars(WebViewTab tab) async {
    await _tabLocker.synchronized(() async {
      await _storage.removeBookmark(tab);
    });
    if (bookmarks.isEmpty) {
      backToBorwser();
    } else {
      notify();
    }
  }

  void clearBookmark() {
    _tabLocker.synchronized(() async {
      await _storage.clearBookmark();
    });

    backToBorwser();
  }

  void backToBorwser() {
    _page = WebViewTabPage.browser;
    notify();
  }

  void showOpenTabs() {
    _page = WebViewTabPage.tabs;
    notify();
  }

  void showHistories() {
    _page = WebViewTabPage.history;
    notify();
  }

  void showBookmarks() {
    _page = WebViewTabPage.bookmarks;
    notify();
  }

  Future<bool> canGoBack() async {
    if (viewType == null) return false;
    return webViewController.canGoBack(viewType!);
  }

  Future<bool> canGoForward() async {
    if (viewType == null) return false;
    return webViewController.canGoForward(viewType!);
  }

  Future<void> goBack() async {
    if (viewType == null) return;
    webViewController.goBack(viewType!);
  }

  Future<void> goForward() async {
    if (viewType == null) return;
    webViewController.goForward(viewType!);
  }

  Future<void> reload() async {
    if (viewType == null) return;
    webViewController.reload(viewType!);
  }

  Future<WebViewTab> _eventToTab(WebViewEvent event) async {
    APPImage image = APPImage.faviIcon(event.url!);
    if (event.favicon != null) {
      final data = await crypto.generateUUID(dataHex: event.favicon);
      image = APPImage.network(event.favicon!, data);
    }
    return WebViewTab(
        url: event.url!,
        title: event.title,
        id: controller.tabId,
        image: image);
  }

  Future<MRTAndroidViewController> _initContiller(String viewId,
      {String? url}) async {
    await webViewController.init(viewId,
        url: url ?? _website,
        jsInterface: _WebViewStateControllerConst.interfaceName);
    final controller = await MRTAndroidViewController.create(viewType: viewId);
    return controller;
  }

  Future<WebViewController> _buildController() async {
    final viewId = await crypto.generateRandomHex(
        length: _WebViewStateControllerConst.viewIdLength,
        existsKeys:
            tabsAuthenticated.values.map((e) => e.viewTypeBytes).toList());
    final key = await crypto.generateRandomBytes();
    final controller = await _initContiller(viewId);
    final tab = WebViewTab(
        id: viewId,
        url: _website,
        title: null,
        image: APPImage.faviIcon(_website));
    final auth = WebViewController(
        controller: controller, viewType: viewId, key: key, tab: tab);
    tabsAuthenticated[auth.viewType] = auth;
    return auth;
  }

  Future<void> _initializeController(WebViewController tab) async {
    if (_currentViewId != null) {
      webViewController.removeListener(this);
    }
    _currentViewId = tab.viewType;
    webViewController.addListener(this);
  }

  Future<void> _initWebView() async {
    await _storage.initRepository();
    final tabs = _storage.tabs;
    for (final i in tabs) {
      final key = await crypto.generateRandomBytes();
      final tabId = await crypto.generateRandomHex(
          length: _WebViewStateControllerConst.viewIdLength,
          existsKeys:
              tabsAuthenticated.values.map((e) => e.viewTypeBytes).toList());
      final controller = await _initContiller(tabId, url: i.url);
      final auth = WebViewController(
          controller: controller, viewType: tabId, key: key, tab: i);
      tabsAuthenticated[tabId] = auth;
    }
    WebViewController controller;
    if (tabsAuthenticated.isNotEmpty) {
      final lastest = _storage.lastTab;
      controller = tabsAuthenticated.values.firstWhere(
          (e) => e.tab.value == lastest,
          orElse: () => tabsAuthenticated.values.first);
    } else {
      controller = await _buildController();
      await _storage.updateTab(controller.tab.value);
    }
    await _initializeController(controller);
    progressKey.backToIdle();
    _inited = true;
    notify();
  }

  Future<void> removeTab(WebViewController auth) async {
    await _storage.removeTab(auth.tab.value);
    final remove = tabsAuthenticated.remove(auth.viewType);
    final last = _storage.lastTab;
    WebViewController? authenticated =
        tabsAuthenticated.values.firstWhereOrNull((e) => e.tabId == last?.id);
    if (authenticated != null) {
      await _initializeController(authenticated);
      if (last == null) {
        backToBorwser();
      }
    } else {
      await newTab((v) {});
    }
    notify();
    remove?.dispose();
  }

  Future<void> addOrRemoveFromBookMark(WebViewTab newTab) async {
    await _storage.addOrRemoveFromBookMark(newTab);
    _inBokmark = _storage.inBokmark(newTab);
  }

  Future<void> newTab(IntVoid reachedLimit) async {
    await _tabLocker.synchronized(() async {
      if (tabsAuthenticated.length > WebViewStorageType.tab.maxStorageLength) {
        reachedLimit(WebViewStorageType.tab.maxStorageLength);
        return;
      }
      final newController = await _buildController();
      await _storage.updateTab(newController.tab.value);
      await _initializeController(newController);
      backToBorwser();
    });
  }

  Future<void> switchTab(WebViewController controller) async {
    await _tabLocker.synchronized(() async {
      if (controller.viewType == viewType) {
        backToBorwser();
        return;
      }
      if (!tabsAuthenticated.containsKey(controller.viewType)) return;
      await _initializeController(controller);
      backToBorwser();
    });
  }

  void onSubmitTextField() {
    String v = (textField.currentState?.getValue() ?? "").trim();
    if (v.isEmpty || _event?.url == v) {
      return;
    }
    if (StrUtils.isValidIPv4WithPort(v)) {
      webViewController.openUrl(viewType: viewType!, url: v);
      return;
    }
    final lower = v.toLowerCase();
    final isDomain = StrUtils.isDomain(v);
    if (isDomain) {
      final uri = Uri.parse(v);
      if (!uri.hasScheme) {
        v = "https://$v";
      }
    } else if (!lower.contains(":/")) {
      v = "${_WebViewStateControllerConst.googleSerchUrl}$v";
    }
    webViewController.openUrl(viewType: viewType!, url: v);
    textField.currentState?.updateText(v);
  }

  Future<void> onBackButton(DynamicVoid callBack) async {
    if (!inBrowser) {
      backToBorwser();
      return;
    }
    if (await canGoBack()) {
      await goBack();
      return;
    }
    callBack();
  }

  Future<void> onPop(DynamicVoid callBack) async {
    if (!inBrowser) {
      backToBorwser();
      return;
    }
    callBack();
  }

  @override
  void onPageStart(WebViewEvent event) {
    final String? url = event.url;
    final lastUrl = lastEvent?.url;

    _event = event;
    if (url == null) return;
    textField.currentState?.updateText(url);
    _tabLocker.synchronized(() async {
      final WebViewTab tab = await _eventToTab(event);
      _inBokmark = _storage.inBokmark(tab);
      controller.setTab(tab);
      final bool changed = url != lastUrl;
      if (changed) {
        _storage.updateTab(tab);
      }
    });
  }

  @override
  void onPageFinished(WebViewEvent event) async {
    if (event.url == null) return;
    _progress.value = null;
    liveNotifier.value = !liveNotifier.value;
    final WebViewTab tab = await _eventToTab(event);
    await _storage.saveHistory(tab);
  }

  @override
  void onPageProgress(WebViewEvent event) {
    if (event.progress == null) {
      return;
    }
    _progress.value = (event.progress! / 100);
  }

  @override
  void onPageError(WebViewEvent event) {
    _progress.value = null;
  }

  void _dipose() async {
    liveNotifier.dispose();
    _progress.dispose();
    for (final i in tabsAuthenticated.values) {
      i.dispose();
    }
  }

  @override
  void close() {
    super.close();
    _dipose();
  }

  @override
  void ready() {
    super.ready();
    _initWebView();
  }
}
