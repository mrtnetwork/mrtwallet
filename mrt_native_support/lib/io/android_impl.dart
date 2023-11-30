part of 'package:mrt_native_support/io/io_platforms.dart';

class IoPlatformInterface extends MrtPlatformInterface {
  static const MethodChannel _methodChannel =
      MethodChannel(MrtNativeConst.channelAuthory);

  static MethodChannel get _channel => _methodChannel;
  IoPlatformInterface() {
    if (Platform.isWindows) {
      _windows = WindowsPlatformInterface();
      _methodChannel.setMethodCallHandler(_windows._methodCallHandler);
    }
  }

  late final WindowsPlatformInterface _windows;
  static final Set<NetworkStatusListener> _networkEventListener = {};

  @override
  Future<bool> secureFlag({required bool isSecure}) async {
    final secure = await _channel.invokeMethod<bool>("secureFlag", {
      'secure': isSecure,
    });

    return secure ?? false;
  }

  @override
  Future<bool> containsKeySecure(String key) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"key": key, "type": "containsKey"});

    return data;
  }

  @override
  Future<Map<String, String>> readAllSecure() async {
    final data = await _channel
        .invokeMethod(MrtNativeConst.secureStorageMethod, {"type": "readAll"});
    return Map<String, String>.from(data!);
  }

  @override
  Future<String?> readSecure(String key) async {
    final data = await _channel.invokeMethod(
        MrtNativeConst.secureStorageMethod, {"key": key, "type": "read"});

    return data;
  }

  @override
  Future<bool> removeAllSecure() async {
    final data = await _channel.invokeMethod(
        MrtNativeConst.secureStorageMethod, {"type": "removeAll"});

    return data;
  }

  @override
  Future<bool> writeSecure(String key, String value) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"type": "write", "key": key, "value": value});

    return data;
  }

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

  @override
  Future<Map<String, String>> readMultipleSecure(List<String> keys) async {
    final data = await _channel.invokeMethod(MrtNativeConst.secureStorageMethod,
        {"keys": keys, "type": "readMultiple"});

    return Map<String, String>.from(data);
  }

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

  @override
  Future<AppPath> path() async {
    final data = await _channel.invokeMethod(MrtNativeConst.pathMethod, {});
    return AppPath.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<bool> launchUri(String uri) async {
    final data = await _channel
        .invokeMethod(MrtNativeConst.launchUriMethod, {"uri": uri});
    return data;
  }

  @override
  WindowsPlatformInterface get window {
    if (Platform.isWindows) {
      return _windows;
    }
    throw UnimplementedError();
  }
}
