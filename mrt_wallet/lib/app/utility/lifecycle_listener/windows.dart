import 'package:mrt_native_support/models/windows_listener.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'core.dart';

class WindowsLifeCycleListener extends AppLifecycleListener
    with WindowListener {
  WindowsLifeCycleListener({required this.onFocus, required this.onHide});
  @override
  void dispose() {
    PlatformInterface.interface.window.removeListener(this);
  }

  @override
  void init() {
    PlatformInterface.interface.window.addListener(this);
  }

  @override
  final DynamicVoid onFocus;

  @override
  final DynamicVoid onHide;

  @override
  void onWindowFocus() {
    onFocus();
    super.onWindowFocus();
  }

  @override
  void onWindowBlur() {
    onHide();
    super.onWindowBlur();
  }
}
