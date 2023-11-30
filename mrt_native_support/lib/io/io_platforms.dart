library io_platform_interface;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/constant/constant.dart';
part 'android_impl.dart';
part 'windows_impl.dart';

MrtPlatformInterface getPlatformInterface() => IoPlatformInterface();
AppPlatform getPlatform() {
  if (Platform.isAndroid) {
    return AppPlatform.android;
  } else if (Platform.isIOS) {
    return AppPlatform.ios;
  } else if (Platform.isWindows) {
    return AppPlatform.windows;
  }
  throw UnimplementedError("app does not support");
}
