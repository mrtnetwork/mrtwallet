// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:typed_data';
import 'dart:js_util' as js_util;

final _subtle =
    js_util.getProperty(js_util.getProperty(window, 'crypto'), "subtle");

class _SubtleMethodNameConst {
  static const String decrypt = "decrypt";
  static const String encrypt = "encrypt";
  static const String exportKey = "exportKey";
  static const String generateKey = "generateKey";
  static const String importKey = "importKey";
}

class SubtleAlgorithm {
  SubtleAlgorithm({required this.iv});

  final List<int> iv;

  Object get object {
    final obj = js_util.newObject();
    js_util.setProperty(obj, "name", 'AES-GCM');
    js_util.setProperty(obj, "length", 256);
    js_util.setProperty(obj, "iv", iv);
    return obj;
  }
}

importKey(
  String format,
  TypedData keyData,
  SubtleAlgorithm algo,
  bool extractable,
  List<String> usages,
) {
  return js_util.callMethod(_subtle, _SubtleMethodNameConst.importKey,
      [format, keyData, algo.object, extractable, usages]);
}

generateKey(
  SubtleAlgorithm algorithm,
  bool extractable,
  List<String> usages,
) {
  return js_util.callMethod(_subtle, _SubtleMethodNameConst.generateKey,
      [algorithm.object, extractable, usages]);
}

exportKey(
  String format,
  CryptoKey key,
) {
  return js_util
      .callMethod(_subtle, _SubtleMethodNameConst.exportKey, [format, key]);
}

encrypt(
  SubtleAlgorithm algorithm,
  CryptoKey key,
  TypedData data,
) {
  return js_util.callMethod(
      _subtle, _SubtleMethodNameConst.encrypt, [algorithm.object, key, data]);
}

decrypt(
  SubtleAlgorithm algorithm,
  CryptoKey key,
  TypedData data,
) {
  return js_util.callMethod(
      _subtle, _SubtleMethodNameConst.decrypt, [algorithm.object, key, data]);
}
