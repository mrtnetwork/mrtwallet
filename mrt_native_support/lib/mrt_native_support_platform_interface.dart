import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'exception/exception.dart';
import 'mrt_native_support_method_channel.dart';

// ignore: camel_case_types
abstract class Mrt_nPlatform extends PlatformInterface {
  /// Constructs a Mrt_nPlatform.
  Mrt_nPlatform() : super(token: _token);

  static final Object _token = Object();

  static Mrt_nPlatform _instance = MethodChannelMrt_n();

  /// The default instance of [Mrt_nPlatform] to use.
  ///
  /// Defaults to [MethodChannelMrt_n].
  static Mrt_nPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Mrt_nPlatform] when
  /// they register themselves.
  static set instance(Mrt_nPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw const MRTNativePluginException(
        'platformVersion() has not been implemented.');
  }
}
