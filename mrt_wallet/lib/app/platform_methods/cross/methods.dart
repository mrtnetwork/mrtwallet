import 'package:mrt_native_support/platform_interface.dart';
import 'cross_platform.dart'
    if (dart.library.js_interop) 'web.dart'
    if (dart.library.io) 'io.dart';

class PlatformMethods {
  static Future<String> writeString(String data, String fileName,
      {bool validate = true}) async {
    return await writeTOFile(data, fileName, validate: validate);
  }

  static Future<String> writeBytes(
      {required List<int> bytes,
      required String fileName,
      bool validate = true}) async {
    return await bytesToFile(
        bytes: bytes, fileName: fileName, validate: validate);
  }

  static Future<List<int>> loadAssets(String assetPath,
      {String? package}) async {
    return await loadAssetBuffer(assetPath, package: package);
  }

  static Future<String> loadAssetsText(String assetPath,
      {String? package}) async {
    return await loadAssetText(assetPath, package: package);
  }

  static String assetPath(String assetPath, {String? package}) {
    return toAssetPath(assetPath, package: package);
  }

  static Future<bool> writeClipboard(String text) async {
    return await PlatformInterface.instance.writeClipboard(text);
  }

  static Future<String?> readClipboard() {
    return PlatformInterface.instance.readClipboard();
  }
}
