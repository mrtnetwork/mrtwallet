import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/webview/controller/controller/tab_controller.dart';
import 'package:mrt_wallet/future/wallet/webview/view/android.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/repository/models/models/webview_repository.dart';
import 'package:mrt_wallet/wroker/impl/worker_impl.dart';

class _WebViewStateControllerConst {
  static const int viewIdLength = 12;
  static const String googleSerchUrl = "https://www.google.com/search?q=";
  static const String webSite = "http://10.0.2.2:3000/";
}

enum WebViewTabPage {
  browser,
  tabs,
  history,
  bookmarks;
}

mixin WebViewTabImpl on StateController, CryptoWokerImpl, WebViewListener {
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

  Future<WebViewController> _buildController() async {
    final viewId = await crypto.generateRandomHex(
        length: _WebViewStateControllerConst.viewIdLength,
        existsKeys:
            tabsAuthenticated.values.map((e) => e.viewTypeBytes).toList());
    final key = await crypto.generateRandomBytes();
    final controller = MRTAndroidViewController.create(viewType: viewId);
    final tab = WebViewTab(
        id: viewId,
        url: _WebViewStateControllerConst.webSite,
        title: null,
        image: APPImage.faviIcon(_WebViewStateControllerConst.webSite));
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
    if (!tab.inited) {
      await webViewController.init(tab.viewType, url: tab.url);
      tab.init();
    }
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
      final controller = MRTAndroidViewController.create(viewType: tabId);
      final auth = WebViewController(
          controller: controller, viewType: tabId, key: key, tab: i);
      tabsAuthenticated[tabId] = auth;
      await webViewController.init(tabId, url: i.url, jsInterface: "MRT");
      auth.init();
    }
    final lastest = _storage.lastTab;
    final lastController =
        tabsAuthenticated.values.firstWhere((e) => e.tab.value == lastest);
    await _initializeController(lastController);
    progressKey.backToIdle();
    notify();
  }

  Future<void> removeTab(WebViewController auth) async {
    await _storage.removeTab(auth.tab.value);
    tabsAuthenticated.remove(auth.viewType);
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
      if (!tabsAuthenticated.containsKey(controller.viewType) ||
          controller.viewType == viewType) return;
      await _initializeController(controller);
      backToBorwser();
    });
  }

  void onSubmitTextField() {
    String v = (textField.currentState?.getValue() ?? "").trim();
    if (v.isEmpty || _event?.url == v) {
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

  @override
  void onPageStart(WebViewEvent event) {
    _event = event;
    final String? url = event.url;
    if (url == null) return;
    textField.currentState?.updateText(url);
    _tabLocker.synchronized(() async {
      final WebViewTab tab = await _eventToTab(event);
      _inBokmark = _storage.inBokmark(tab);
      controller.setTab(tab);
      final bool changed = url != _event?.url;
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

  @override
  void close() {
    super.close();
    for (final i in tabsAuthenticated.values) {
      i.controller.dispose();
    }
    liveNotifier.dispose();
    _progress.dispose();
  }

  @override
  void ready() {
    super.ready();
    _initWebView();
  }
}
