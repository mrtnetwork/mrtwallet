import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/platform_interface.dart';

mixin BaseNativeMEthod {
  static MrtPlatformInterface platform = PlatformInterface.instance;
}
