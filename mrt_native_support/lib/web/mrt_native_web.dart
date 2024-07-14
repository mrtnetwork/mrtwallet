// ignore_for_file: avoid_web_libraries_in_flutter

library mrt_native_web;

import 'dart:convert';
import 'dart:typed_data';
import 'package:mrt_native_support/exception/exception.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'web_storage/web_storage.dart' as crypto;
import 'dart:html' as html;
import 'dart:js_util' as js_util;
part 'web_storage/decrypt.dart';

MrtPlatformInterface getPlatformInterface() => MrtNativeWeb();
AppPlatform getPlatform() => AppPlatform.web;

class MrtNativeWeb extends MrtPlatformInterface {
  @override
  void addNetworkListener(NetworkStatusListener listener) {}

  @override
  Future<bool> containsKeySecure(String key) {
    return Future.value(
      html.window.localStorage.containsKey("$storageKey.$key"),
    );
  }

  @override
  Future<NetworkEvent> deviceConnectionStatus() {
    throw MRTNativePluginException.unsuported;
  }

  @override
  Future<DeviceInfo> getDeviceInfo() {
    throw MRTNativePluginException.unsuported;
  }

  @override
  Future<Map<String, String>> readAllSecure() async {
    final map = <String, String>{};
    const prefix = "$storageKey.";
    for (int j = 0; j < html.window.localStorage.length; j++) {
      final entry = html.window.localStorage.entries.elementAt(j);
      if (!entry.key.startsWith(prefix)) {
        continue;
      }

      final value = await decryptValue(entry.value);

      if (value == null) {
        continue;
      }

      map[entry.key.substring(prefix.length)] = value;
    }
    return map;
  }

  @override
  Future<Map<String, String>> readMultipleSecure(List<String> keys) async {
    final map = <String, String>{};
    for (final foo in keys) {
      final exist = html.window.localStorage["$storageKey.$foo"];
      final value = await decryptValue(exist);
      if (value == null) {
        continue;
      }
      map[foo] = value;
    }
    return map;
  }

  @override
  Future<String?> readSecure(String key) {
    final value = html.window.localStorage["$storageKey.$key"];

    return decryptValue(value);
  }

  @override
  Future<bool> removeAllSecure() async {
    await Future.sync(
      () => html.window.localStorage.removeWhere((key, value) => true),
    );
    return true;
  }

  @override
  Future<bool> removeMultipleSecure(List<String> keys) async {
    List<String> currentKeys = keys.map((e) => "$storageKey.$e").toList();
    await Future.sync(() => html.window.localStorage
        .removeWhere((key, value) => currentKeys.contains(key)));
    return true;
  }

  @override
  void removeNetworkListener(NetworkStatusListener listener) {}

  @override
  Future<bool> removeSecure(String key) async {
    html.window.localStorage.remove("$storageKey.$key");
    return true;
  }

  @override
  Future<bool> secureFlag({required bool isSecure}) async {
    return false;
  }

  @override
  Future<bool> writeSecure(String key, String value) async {
    final iv =
        html.window.crypto!.getRandomValues(Uint8List(12)).buffer.asUint8List();

    final algorithm = toSubtleAlgo(iv);

    final encryptionKey = await getEncryptionKey(algorithm);

    final encryptedContent = await encrypt(algorithm, encryptionKey, value);
    final encoded =
        "${base64Encode(iv)}.${base64Encode(encryptedContent.asUint8List())}";

    html.window.localStorage["$storageKey.$key"] = encoded;
    return true;
  }

  @override
  Future<bool> share(Share share) {
    return _share(share);
  }

  String _toFilePath(String path) {
    if (path.startsWith("blob:")) {
      return path.replaceFirst("blob:", "");
    }
    return path;
  }

  Future<bool> _share(Share share) async {
    try {
      List<html.File> files = [];
      if (share.isFile) {
        final response = await html.window.fetch(_toFilePath(share.path!));
        int code = js_util.getProperty(response, 'status');
        if (code != 200) return false;
        ByteBuffer textPromise = await js_util.promiseToFuture(
            js_util.callMethod<Object>(response, 'arrayBuffer', []));
        final html.File file = html.File([textPromise.asByteData()],
            share.fileName!, {'type': share.getMimeType()});
        files.add(file);
      }

      await html.window.navigator.share({
        if (files.isNotEmpty) 'files': files,
        if (share.text != null) 'text': share.text,
        if (share.subject != null) 'title': share.subject
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AppPath> path() {
    throw MRTNativePluginException.unsuported;
  }

  @override
  Future<bool> launchUri(String uri) async {
    html.window.open(uri, "", 'noopener,noreferrer');
    return true;
  }

  @override
  SpecificPlatfromMethods get desktop => throw UnimplementedError(
      "only available in desktop platforms (windows, macos)");

  @override
  Future<Stream<BarcodeScannerResult>> startBarcodeScanner(
      {BarcodeScannerParams param = const EmptyBarcodeScannerParams()}) {
    throw MRTNativePluginException.unsuported;
  }

  @override
  Future<void> stopBarcodeScanner() {
    throw MRTNativePluginException.unsuported;
  }

  @override
  Future<bool> hasBarcodeScanner() async {
    return js_util.hasProperty(html.window, "BarcodeDetector");
  }

  @override
  Future<MRTAPPConfig> getConfig() async {
    final barcode = await hasBarcodeScanner().catchError((e) => false);
    return MRTAPPConfig(platform: getPlatform(), hasBarcodeScanner: barcode);
  }
}
