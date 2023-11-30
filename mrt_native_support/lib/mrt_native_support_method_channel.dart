import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mrt_native_support_platform_interface.dart';

/// An implementation of [Mrt_nPlatform] that uses method channels.
class MethodChannelMrt_n extends Mrt_nPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mrt_n');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
