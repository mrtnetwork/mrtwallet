enum AppPlatform {
  windows,
  web,
  android,
  ios,
  macos;

  bool get isDesktop =>
      this == AppPlatform.windows || this == AppPlatform.macos;
}
