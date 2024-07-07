/// This Flutter plugin incorporates code inspired by the following projects:

/// 1. [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Some of the methods in this plugin are inspired by the flutter_secure_storage plugin, which is licensed under the BSD license. The original project can be found at: https://github.com/mogol/flutter_secure_storage
/// 2. [window_manager](https://pub.dev/packages/window_manager) - Additionally, some methods are inspired by the window_manager plugin, which is licensed under the MIT license. The original project can be found at: https://github.com/leanflutter/window_manager

import 'dart:async';
import 'dart:ui';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/barcode/models/barcode_scanner_result.dart';
import 'models/models.dart';

abstract class MrtPlatformInterface extends PlatformInterface {
  MrtPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MrtNativePlatform] when
  /// they register themselves.
  static set instance(MrtPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  static void registerWith() {}

  Future<bool> secureFlag({required bool isSecure});

  Future<String?> readSecure(String key);
  Future<bool> writeSecure(String key, String value);
  Future<bool> containsKeySecure(String key);
  Future<Map<String, String>> readAllSecure();
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
  abstract final SpecificPlatfromMethods desktop;
  Future<Stream<BarcodeScannerResult>> startBarcodeScanner(
      {required BarcodeScannerParams param});
  Future<void> stopBarcodeScanner();
  Future<bool> hasBarcodeScanner();
}

abstract class SpecificPlatfromMethods {
  Future<bool> show();
  Future<bool> hide();
  Future<bool> init();
  Future<void> setBounds(Rect? bounds,
      {Offset? position, Size? size, bool animate = false});

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
  Future<Rect> getBounds();

  void addListener(WindowListener listener);

  void removeListener(WindowListener listener);
}
