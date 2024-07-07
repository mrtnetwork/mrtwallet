library io_platform_interface;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mrt_native_support/exception/exception.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/constant/constant.dart';
part 'io_impl.dart';
part 'desktop_impl.dart';

MrtPlatformInterface getPlatformInterface() => IoPlatformInterface();
AppPlatform getPlatform() {
  if (Platform.isAndroid) {
    return AppPlatform.android;
  } else if (Platform.isIOS) {
    return AppPlatform.ios;
  } else if (Platform.isWindows) {
    return AppPlatform.windows;
  } else if (Platform.isMacOS) {
    return AppPlatform.macos;
  }
  throw UnimplementedError("app does not support");
}
