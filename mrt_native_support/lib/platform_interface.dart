library mrt_platform_interface;

import 'package:mrt_native_support/base.dart'
    if (dart.library.js_interop) 'web/mrt_native_web.dart'
    if (dart.library.io) 'io/io_platforms.dart';
import 'package:mrt_native_support/models/models.dart';
import 'mrt_native_support.dart';

class PlatformInterface {
  static final MrtPlatformInterface instance = getPlatformInterface();
  static AppPlatform get appPlatform => instance.platform;
  static bool get isWindows => appPlatform == AppPlatform.windows;
  static bool get isWeb => appPlatform == AppPlatform.web;
  static bool get isMacos => appPlatform == AppPlatform.macos;
  static PlatformWebView get webViewController => instance.webView;
  static bool get supportWebView => webViewController.supported;
}
