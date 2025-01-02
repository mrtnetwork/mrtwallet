import 'package:mrt_native_support/exception/exception.dart';

enum AppPlatform {
  windows,
  web,
  android,
  ios,
  macos;

  bool get isDesktop =>
      this == AppPlatform.windows || this == AppPlatform.macos;

  static AppPlatform fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () =>
          throw const MRTNativePluginException("Invalid platform name."),
    );
  }
}
