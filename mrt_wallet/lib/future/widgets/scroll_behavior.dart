import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/models.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior(this.platform);
  final AppPlatform platform;
  bool get isWindowsOrWeb =>
      platform == AppPlatform.windows || platform == AppPlatform.web;
  @override
  Set<PointerDeviceKind> get dragDevices => isWindowsOrWeb
      ? {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }
      : super.dragDevices;
}
