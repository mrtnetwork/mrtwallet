import 'package:mrt_native_support/mrt_native_support.dart';
import 'exception/exception.dart';

MrtPlatformInterface getPlatformInterface() {
  throw const MRTNativePluginException(
      'Cannot create a client instance dart:html or dart:io.');
}
