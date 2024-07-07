part of 'package:mrt_native_support/io/io_platforms.dart';

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
    switch (call.method) {
      case "onEvent":
        if (Platform.isWindows || Platform.isMacOS) {
          _desktop._methodCallHandler(call);
          break;
        }
        break;
      case "onBarcodeScanned":
        _barcodeListener?.add(BarcodeScannerResult.fromJson(
            Map<String, dynamic>.from(call.arguments)));
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
  Future<Map<String, String>> readAllSecure() async {
    final data = await _channel
        .invokeMethod(MrtNativeConst.secureStorageMethod, {"type": "readAll"});
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
    throw UnimplementedError(
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
    await _channel.invokeMethod("stopBarcodeScanner");
    _barcodeListener?.close();
    _barcodeListener = null;
  }

  @override
  Future<bool> hasBarcodeScanner() async {
    if (Platform.isWindows) return false;
    final hasBarcode = await _channel.invokeMethod<bool>("hasBarcodeScanner");
    return hasBarcode ?? false;
  }
}
