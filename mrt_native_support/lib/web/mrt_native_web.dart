library mrt_native_web;

export 'api/api.dart';
export 'wallet/event.dart';
export 'storage/storage.dart';
import 'dart:js_interop';
import 'package:mrt_native_support/exception/exception.dart';
import 'package:mrt_native_support/models/models.dart';
import 'package:mrt_native_support/mrt_native_support.dart';
import 'package:mrt_native_support/web/api/window/window.dart';
import 'package:mrt_native_support/web/storage/safe_storage/safestorage.dart';

MrtPlatformInterface getPlatformInterface() => MrtNativeWeb._();

class MrtNativeWeb extends MrtPlatformInterface {
  MrtNativeWeb._();
  late SafeStorage storage;

  @override
  void addNetworkListener(NetworkStatusListener listener) {}

  @override
  Future<bool> containsKeySecure(String key) async {
    final data = await storage.read(key);
    return data != null;
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
  Future<Map<String, String>> readAllSecure({String? prefix}) async {
    return storage.all(prefix: prefix);
  }

  @override
  Future<Map<String, String>> readMultipleSecure(List<String> keys) async {
    return storage.reads(keys);
  }

  @override
  Future<String?> readSecure(String key) async {
    return storage.read(key);
  }

  @override
  Future<bool> removeAllSecure() async {
    await storage.clear();
    storage = await SafeStorage.init();
    return true;
  }

  @override
  Future<bool> removeMultipleSecure(List<String> keys) async {
    await storage.removes(keys);
    return true;
  }

  @override
  void removeNetworkListener(NetworkStatusListener listener) {}

  @override
  Future<bool> removeSecure(String key) async {
    await storage.remove(key);
    return true;
  }

  @override
  Future<bool> secureFlag({required bool isSecure}) async {
    return false;
  }

  @override
  Future<bool> writeSecure(String key, String value) async {
    await storage.save(key, value);
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
      List<JSFile> files = [];
      if (share.isFile) {
        final response = await jsWindow.fetch_(_toFilePath(share.path!));
        if (response.status != 200) return false;
        final file = JSFile([await response.arrayBuffer().toDart].toJS,
            share.fileName!, JSFileOption(type: share.getMimeType()));
        files.add(file);
      }
      await jsWindow.navigator
          .share_(title: share.subject, text: share.text, files: files);
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
    final result = jsWindow.open(uri, null, 'noopener,noreferrer');
    return result != null;
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
    return jsWindow.barcode != null;
  }

  @override
  Future<MRTAPPConfig> getConfig() async {
    storage = await SafeStorage.init();
    final barcode = await hasBarcodeScanner().catchError((e) => false);
    return MRTAPPConfig(platform: platform, hasBarcodeScanner: barcode);
  }

  @override
  PlatformWebView get webView => throw UnimplementedError();

  @override
  AppPlatform get platform => AppPlatform.web;

  @override
  Future<String?> readClipboard() async {
    return jsWindow.navigatorNullable?.clipboard?.readText_();
  }

  @override
  Future<bool> writeClipboard(String text) async {
    return await jsWindow.navigatorNullable?.clipboard?.writeText_(text) ??
        false;
  }
}
