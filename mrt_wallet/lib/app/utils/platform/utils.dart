import 'package:mrt_wallet/app/core.dart';

class PlatformUtils {
  static Future<String> writeString(String data, String fileName,
      {bool validate = true}) async {
    return await PlatformMethods.writeString(data, fileName,
        validate: validate);
  }

  static Future<String> writeBytes(
      {required List<int> bytes,
      required String fileName,
      bool validate = true}) async {
    return await PlatformMethods.writeBytes(
        bytes: bytes, fileName: fileName, validate: validate);
  }

  static Future<List<int>> loadAssets(String assetPath) async {
    return await PlatformMethods.loadAssets(assetPath);
  }

  static Future<String> loadAssetText(String assetPath) async {
    return await PlatformMethods.loadAssetsText(assetPath);
  }

  static String assetPath(String assetPath) {
    return PlatformMethods.assetPath(assetPath);
  }

  static Future<bool> writeClipboard(String text) async {
    return await PlatformMethods.writeClipboard(text);
  }

  static Future<String?> readClipboard() {
    return PlatformMethods.readClipboard();
  }
}
