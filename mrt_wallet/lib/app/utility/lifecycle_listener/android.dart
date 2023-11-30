import 'dart:ui';

import 'package:flutter/material.dart'
    show WidgetsBindingObserver, WidgetsBinding;
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/utility/lifecycle_listener/windows.dart';
import 'package:mrt_wallet/types/typedef.dart';

import 'core.dart';

AppLifecycleListener platformLifeCycel(
    DynamicVoid onHide, DynamicVoid onFocus) {
  if (PlatformInterface.isWindows) {
    return WindowsLifeCycleListener(onFocus: onFocus, onHide: onHide);
  }
  return AndroidLifeCycleListener(onHide: onHide, onFocus: onFocus);
}

class AndroidLifeCycleListener extends AppLifecycleListener
    with WidgetsBindingObserver {
  AndroidLifeCycleListener({required this.onFocus, required this.onHide});
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  final DynamicVoid onFocus;

  @override
  final DynamicVoid onHide;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    super.didChangeAppLifecycleState(state);
  }
}
