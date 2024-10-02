part of 'package:mrt_native_support/io/io_platforms.dart';

class _IoPlatformConst {
  static const String desktopEvent = "onEvent";
  static const String webViewEvent = "webView";
  static const String barcodeScannerEvent = "onBarcodeScanned";
}

class IoPlatformInterface extends MrtPlatformInterface {
  static const MethodChannel _methodChannel =
      MethodChannel(MrtNativeConst.channelAuthory);

  StreamController<BarcodeScannerResult>? _barcodeListener;

  static MethodChannel get _channel => _methodChannel;
  IoPlatformInterface() {
    if (Platform.isWindows || Platform.isMacOS) {
      _desktop = DesktopPlatformInterface();
    }
    _methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    final Map<String, dynamic> data;
    try {
      data = (call.arguments as Map).cast();
    } catch (e) {
      return;
    }
    switch (call.method) {
      case _IoPlatformConst.desktopEvent:
        if (Platform.isWindows || Platform.isMacOS) {
          _desktop._methodCallHandler(data);
        }
        break;
      case _IoPlatformConst.webViewEvent:
        webView._methodCallHandler(data);
        break;
      case _IoPlatformConst.barcodeScannerEvent:
        _barcodeListener?.add(BarcodeScannerResult.fromJson(data));
        break;
      default:
    }
  }

  late final DesktopPlatformInterface _desktop;
  static final Set<NetworkStatusListener> _networkEventListener = {};

  @override
  Future<bool> secureFlag({required bool isSecure}) async {
    final secure = await _channel.invokeMethod<bool>("secureFlag", {
      'secure': isSecure,
    });

    return secure ?? false;
  }

  /// ios
  @override
  Future<bool> containsKeySecure(String key) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"key": key, "type": "containsKey"});

    return data;
  }

  /// ios
  @override
  Future<Map<String, String>> readAllSecure({String? prefix}) async {
    final data = await _channel
        .invokeMethod(MrtNativeConst.secureStorageMethod, {"type": "readAll"});

    Map<String, String> values = Map<String, String>.from(data!);
    if (prefix != null) {
      values = values..removeWhere((k, v) => !k.startsWith(prefix));
    }
    return Map<String, String>.from(data!);
  }

  /// ios
  @override
  Future<String?> readSecure(String key) async {
    final data = await _channel.invokeMethod(
        MrtNativeConst.secureStorageMethod, {"key": key, "type": "read"});

    return data;
  }

  /// ios
  @override
  Future<bool> removeAllSecure() async {
    final data = await _channel.invokeMethod(
        MrtNativeConst.secureStorageMethod, {"type": "removeAll"});

    return data;
  }

  /// ios
  @override
  Future<bool> writeSecure(String key, String value) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"type": "write", "key": key, "value": value});

    return data;
  }

  /// ios
  @override
  Future<bool> removeSecure(String key) async {
    final data = await _channel.invokeMethod(
        MrtNativeConst.secureStorageMethod, {"type": "remove", "key": key});
    return data;
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final data = await _channel.invokeMethod(MrtNativeConst.deviceInfo, {});
    return DeviceInfo.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<NetworkEvent> deviceConnectionStatus() async {
    final data = await _channel.invokeMethod(MrtNativeConst.network, {});
    return NetworkEvent.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  void addNetworkListener(NetworkStatusListener listener) {
    _networkEventListener.add(listener);
  }

  @override
  void removeNetworkListener(NetworkStatusListener listener) {
    _networkEventListener.remove(listener);
  }

  /// ios
  @override
  Future<Map<String, String>> readMultipleSecure(List<String> keys) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"keys": keys, "type": "readMultiple"});

    return Map<String, String>.from(data);
  }

  /// ios
  @override
  Future<bool> removeMultipleSecure(List<String> keys) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"keys": keys, "type": "removeMultiple"});
    return data;
  }

  @override
  Future<bool> share(Share share) async {
    final data =
        await _channel.invokeMethod(MrtNativeConst.shareMethod, share.toJson());
    return data;
  }

  // ios
  @override
  Future<AppPath> path() async {
    final data = await _channel.invokeMethod(MrtNativeConst.pathMethod, {});
    return AppPath.fromJson(Map<String, dynamic>.from(data));
  }

  // ios
  @override
  Future<bool> launchUri(String uri) async {
    final data = await _channel
        .invokeMethod(MrtNativeConst.launchUriMethod, {"uri": uri});
    return data;
  }

  @override
  DesktopPlatformInterface get desktop {
    if (Platform.isWindows || Platform.isMacOS) {
      return _desktop;
    }
    throw const MRTNativePluginException(
        "only available in desktop platforms (windows, macos)");
  }

  @override
  Future<Stream<BarcodeScannerResult>> startBarcodeScanner(
      {required BarcodeScannerParams param}) async {
    if (_barcodeListener != null) {
      throw const MRTNativePluginException("Service already running.");
    }
    await _channel.invokeMethod("startBarcodeScanner", param.toJson());
    _barcodeListener ??= StreamController();
    _barcodeListener?.onCancel = () {
      _channel.invokeMethod("stopBarcodeScanner");
      _barcodeListener?.close();
      _barcodeListener = null;
    };
    return _barcodeListener!.stream;
  }

  @override
  Future<void> stopBarcodeScanner() async {
    await _channel.invokeMethod("stopBarcodeScanner", {});
    _barcodeListener?.close();
    _barcodeListener = null;
  }

  @override
  Future<bool> hasBarcodeScanner() async {
    if (Platform.isWindows || Platform.isLinux) return false;
    if (Platform.isAndroid) return true;
    final hasBarcode = await _channel.invokeMethod<bool>("hasBarcodeScanner");
    return hasBarcode ?? false;
  }

  @override
  Future<MRTAPPConfig> getConfig() async {
    final barcode = await hasBarcodeScanner().catchError((e) => false);
    return MRTAPPConfig(platform: platform, hasBarcodeScanner: barcode);
  }

  @override
  final WebViewIoInterface webView = WebViewIoInterface();
  AppPlatform _getPlatform() {
    if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    } else if (Platform.isWindows) {
      return AppPlatform.windows;
    } else if (Platform.isMacOS) {
      return AppPlatform.macos;
    }
    throw const MRTNativePluginException("Unknown platform.");
  }

  @override
  late final AppPlatform platform = _getPlatform();

  @override
  Future<String?> readClipboard() async {
    final data =
        await Clipboard.getData(Clipboard.kTextPlain).catchError((e) => null);
    return data?.text;
  }

  @override
  Future<bool> writeClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (_) {
      return false;
    }
  }
}
