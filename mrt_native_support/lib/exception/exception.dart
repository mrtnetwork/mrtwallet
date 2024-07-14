class MRTNativePluginException implements Exception {
  final String message;
  const MRTNativePluginException(this.message);
  static MRTNativePluginException unsuported =
      const MRTNativePluginException("Unsuported feature.");
}
