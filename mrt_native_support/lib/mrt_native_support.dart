/// This Flutter plugin incorporates code inspired by the following projects:

/// 1. [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Some of the methods in this plugin are inspired by the flutter_secure_storage plugin, which is licensed under the BSD license. The original project can be found at: https://github.com/mogol/flutter_secure_storage
/// 2. [window_manager](https://pub.dev/packages/window_manager) - Additionally, some methods are inspired by the window_manager plugin, which is licensed under the MIT license. The original project can be found at: https://github.com/leanflutter/window_manager

import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/models.dart';

abstract class MrtPlatformInterface extends PlatformInterface {
  MrtPlatformInterface() : super(token: _token);
  static final Object _token = Object();
  abstract final SpecificPlatfromMethods desktop;
  abstract final PlatformWebView webView;
  AppPlatform get platform;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlatformInterface] when
  /// they register themselves.
  static set instance(MrtPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  static void registerWith() {}

  Future<bool> secureFlag({required bool isSecure});

  Future<String?> readSecure(String key);
  Future<bool> writeSecure(String key, String value);
  Future<bool> containsKeySecure(String key);
  Future<Map<String, String>> readAllSecure({String? prefix});
  Future<Map<String, String>> readMultipleSecure(List<String> keys);
  Future<bool> removeMultipleSecure(List<String> keys);
  Future<bool> removeAllSecure();
  Future<bool> removeSecure(String key);
  Future<bool> share(Share share);
  Future<AppPath> path();
  Future<DeviceInfo> getDeviceInfo();
  Future<bool> launchUri(String uri);
  Future<NetworkEvent> deviceConnectionStatus();
  void addNetworkListener(NetworkStatusListener listener);
  void removeNetworkListener(NetworkStatusListener listener);

  Future<Stream<BarcodeScannerResult>> startBarcodeScanner(
      {required BarcodeScannerParams param});
  Future<void> stopBarcodeScanner();
  Future<bool> hasBarcodeScanner();
  Future<MRTAPPConfig> getConfig();

  Future<String?> readClipboard();
  Future<bool> writeClipboard(String text);
}

abstract class PlatformWebView {
  bool get supported;
  Future<Object?> loadScript(
      {required String viewType, required String script});
  Future<void> openUrl({required String viewType, required String url});
  Future<bool> canGoForward(String viewType);
  Future<bool> canGoBack(String viewType);
  Future<void> goBack(String viewType);
  Future<void> goForward(String viewType);
  Future<void> reload(String viewType);
  Future<void> dispose(String viewType);
  Future<void> addJsInterface({required String viewType, required String name});
  Future<void> removeJsInterface(
      {required String viewType, required String name});
  Future<void> updateFrame(
      {required String viewType, required WidgetSize size});
  Future<void> init(String viewType,
      {String url = "https://google.com", String? jsInterface = "MRT"});
  void addListener(WebViewListener listener);
  void removeListener(WebViewListener listener);
}

abstract class SpecificPlatfromMethods {
  Future<bool> show();
  Future<bool> hide();
  Future<bool> init();
  Future<bool> setMaximumSize(WidgetSize size);
  Future<bool> setMinimumSize(WidgetSize size);
  Future<void> setBounds(
      {required double pixelRatio,
      WidgetRect? bounds,
      WidgetOffset? position,
      WidgetSize? size,
      bool animate = false});

  Future<bool> setFullScreen(bool isFullScreen);
  Future<bool> isFullScreen();
  Future<bool> restore();
  Future<bool> minimize();
  Future<bool> isMinimized();
  Future<bool> unmaximize();
  Future<bool> isMaximized();
  Future<bool> isVisible();
  Future<void> waitUntilReadyToShow();
  Future<bool> isFocused();
  Future<bool> blur();
  Future<bool> focus();
  Future<bool> isPreventClose();
  Future<bool> close();
  Future<bool> setAsFrameless();
  Future<bool> isResizable();
  Future<bool> setResizable(bool isResizable);
  Future<WidgetRect> getBounds(double pixelRatio);

  void addListener(WindowListener listener);

  void removeListener(WindowListener listener);
}
