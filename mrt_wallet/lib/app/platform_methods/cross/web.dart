// ignore: avoid_web_libraries_in_flutter

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/error/exception/generic_exception.dart';

Future<String> writeTOFile(String data, String fileName,
    {bool validate = true}) async {
  return jsWindow.document
      .downloadFile(fileBytes: StringUtils.encode(data), fileName: fileName);
}

Future<String> bytesToFile(
    {required List<int> bytes,
    required String fileName,
    bool validate = true}) async {
  return jsWindow.document.downloadFile(fileBytes: bytes, fileName: fileName);
}

Future<List<int>> loadAssetBuffer(String assetPath) async {
  assetPath = toAssetPath(assetPath);
  if (isExtension) {
    assetPath = extension.runtime.getURL(assetPath);
  }
  final data = await jsWindow.fetch_(assetPath);
  if (!data.ok) {
    throw const GenericException("file_does_not_exist");
  }
  final buffer = await data.arrayBuffer_();
  return buffer.asUint8List();
}

Future<String> loadAssetText(String assetPath) async {
  assetPath = toAssetPath(assetPath);
  if (isExtension) {
    assetPath = extension.runtime.getURL(assetPath);
  }
  final data = await jsWindow.fetch_(assetPath);
  if (!data.ok) {
    throw const GenericException("file_does_not_exist");
  }
  return await data.text_();
}

String toAssetPath(String assetPath) {
  return "assets/$assetPath";
}

Future<void> writeClipboard(String text) async {
  await PlatformInterface.instance.writeClipboard(text);
}

Future<String?> readClipboard() {
  return PlatformInterface.instance.readClipboard();
}
