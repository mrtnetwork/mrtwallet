// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:blockchain_utils/blockchain_utils.dart';

Future<String> writeTOFile(String data, String fileName,
    {bool validate = true}) async {
  return _write(StringUtils.encode(data), fileName);
}

Future<String> bytesToFile(
    {required List<int> bytes,
    required String fileName,
    bool validate = true}) async {
  return _write(bytes, fileName);
}

Future<String> _write(List<int> bytes, String fileName) async {
  final html.Blob blob = html.Blob([bytes]);
  final String url = html.Url.createObjectUrlFromBlob(blob);

  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..target = 'download'
    ..download = fileName;

  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);

  html.Url.revokeObjectUrl(url);
  return url;
}
