import 'dart:ui';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/lifecycle_listener/windows.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:flutter/material.dart' as listener;

AppLifecycleListener platformLifeCycel(
    DynamicVoid onHide, DynamicVoid onFocus) {
  if (PlatformInterface.isWindows) {
    return WindowsLifeCycleListener(onFocus: onFocus, onHide: onHide);
  }
  return AndroidLifeCycleListener(onHide: onHide, onFocus: onFocus);
}

class AndroidLifeCycleListener extends AppLifecycleListener {
  AndroidLifeCycleListener({required this.onFocus, required this.onHide});
  listener.AppLifecycleListener? _listener;

  @override
  void dispose() {
    _listener?.dispose();
    _listener = null;
  }

  @override
  void init() {
    _listener?.dispose();
    _listener = listener.AppLifecycleListener(onStateChange: _onStateChanged);
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onFocus();
        break;
      case AppLifecycleState.inactive:
        break;
      default:
        onHide();
        break;
    }
  }

  @override
  final DynamicVoid onFocus;

  @override
  final DynamicVoid onHide;
}
