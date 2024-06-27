import 'cross_platform.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart';

class CrossFileWriter {
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
}
