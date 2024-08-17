import 'package:mrt_wallet/app/core.dart';

class FileUtils {
  static Future<String> writeString(String data, String fileName,
      {bool validate = true}) async {
    return await CrossFileWriter.writeString(data, fileName,
        validate: validate);
  }

  static Future<String> writeBytes(
      {required List<int> bytes,
      required String fileName,
      bool validate = true}) async {
    return await CrossFileWriter.writeBytes(
        bytes: bytes, fileName: fileName, validate: validate);
  }

  static Future<List<int>> loadAssets(String assetPath) async {
    return await CrossFileWriter.loadAssets(assetPath);
  }

  static Future<String> loadAssetText(String assetPath) async {
    return await CrossFileWriter.loadAssetsText(assetPath);
  }
}
