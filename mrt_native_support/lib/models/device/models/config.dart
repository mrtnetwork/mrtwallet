import 'package:mrt_native_support/models/device/models/platform.dart';

class MRTAPPConfig {
  static const int _storageVersion = 1;
  final AppPlatform platform;
  final bool hasBarcodeScanner;
  final int storageVersion;
  const MRTAPPConfig(
      {required this.platform,
      required this.hasBarcodeScanner,
      this.storageVersion = _storageVersion});
}
