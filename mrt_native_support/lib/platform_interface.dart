library mrt_platform_interface;

import 'package:mrt_native_support/base.dart'
    if (dart.library.html) 'web/mrt_native_web.dart'
    if (dart.library.io) 'io/io_platforms.dart';
import 'package:mrt_native_support/models/models.dart';

import 'mrt_native_support.dart';

class PlatformInterface {
  static final MrtPlatformInterface interface = getPlatformInterface();
  static final AppPlatform appPlatform = getPlatform();
  static bool get isWindows => appPlatform == AppPlatform.windows;
  static bool get isWeb => appPlatform == AppPlatform.web;
}
