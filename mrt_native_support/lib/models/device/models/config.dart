import 'package:mrt_native_support/models/device/models/platform.dart';

class MRTAPPConfig {
  final AppPlatform platform;
  final bool hasBarcodeScanner;
  const MRTAPPConfig({required this.platform, required this.hasBarcodeScanner});
}
