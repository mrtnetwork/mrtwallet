import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/models/device/models/platform.dart';
import 'package:mrt_native_support/models/events/models/windows_listener.dart';
import 'package:mrt_native_support/models/size/models/rect.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class _WindowsFrameTracker with WindowListener {
  final DynamicVoid onChange;
  const _WindowsFrameTracker(this.onChange);

  @override
  void onWindowResize() {
    super.onWindowResize();
    onChange();
  }

  @override
  void onWindowMove() {
    super.onWindowMove();
    onChange();
  }
}

mixin DesktopFrameTracker on StateController {
  late _WindowsFrameTracker _tracker;
  Future<void> onUpdateFrame(WidgetRect rect);
  GlobalKey<NavigatorState>? get navigatorKey;
  Timer? _onUpdateFrame;
  Future<void> _updateFrame() async {
    final pixelRatio =
        navigatorKey?.currentContext?.mediaQuery.devicePixelRatio;
    if (pixelRatio == null) return;
    WidgetRect rect =
        await PlatformInterface.instance.desktop.getBounds(pixelRatio);
    rect = rect.copyWith(devicePixelRatio: pixelRatio);
    await onUpdateFrame(rect);
  }

  void _start() {
    if (AppNativeMethods.platform.platform == AppPlatform.windows) {
      _tracker = _WindowsFrameTracker(_detectFrame);
      PlatformInterface.instance.desktop.addListener(_tracker);
    }
  }

  void _detectFrame() {
    _onUpdateFrame?.cancel();
    _onUpdateFrame = null;
    _onUpdateFrame = Timer(APPConst.twoSecoundDuration, _updateFrame);
  }

  @override
  void init() {
    super.init();
    _start();
  }
}
