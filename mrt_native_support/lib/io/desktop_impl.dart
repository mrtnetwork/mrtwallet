part of 'package:mrt_native_support/io/io_platforms.dart';

class DesktopPlatformInterface implements SpecificPlatfromMethods {
  static const _kWindowEventClose = 'close';
  static const _kWindowEventFocus = 'focus';
  static const _kWindowEventBlur = 'blur';
  static const _kWindowEventMaximize = 'maximize';
  static const _kWindowEventUnmaximize = 'unmaximize';
  static const _kWindowEventMinimize = 'minimize';
  static const _kWindowEventRestore = 'restore';
  static const _kWindowEventResize = 'resize';
  static const _kWindowEventResized = 'resized';
  static const _kWindowEventMove = 'move';
  static const _kWindowEventMoved = 'moved';
  static const _kWindowEventEnterFullScreen = 'enter-full-screen';
  static const _kWindowEventLeaveFullScreen = 'leave-full-screen';
  static const _kWindowEventDocked = 'docked';
  static const _kWindowEventUndocked = 'undocked';
  final ObserverList<WindowListener> _listeners =
      ObserverList<WindowListener>();

  /// ios
  @override
  Future<bool> hide() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "hide"});
    return data;
  }

  List<WindowListener> get listeners {
    final List<WindowListener> localListeners =
        List<WindowListener>.from(_listeners);
    return localListeners;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  @override
  void addListener(WindowListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(WindowListener listener) {
    _listeners.remove(listener);
  }

  Future<void> _methodCallHandler(Map<String, dynamic> args) async {
    String? eventName = args['eventName'];
    if (eventName == null) {
      return;
    }
    for (final WindowListener listener in listeners) {
      if (!_listeners.contains(listener)) {
        return;
      }

      listener.onWindowEvent(eventName);
      Map<String, Function> funcMap = {
        _kWindowEventClose: listener.onWindowClose,
        _kWindowEventFocus: listener.onWindowFocus,
        _kWindowEventBlur: listener.onWindowBlur,
        _kWindowEventMaximize: listener.onWindowMaximize,
        _kWindowEventUnmaximize: listener.onWindowUnmaximize,
        _kWindowEventMinimize: listener.onWindowMinimize,
        _kWindowEventRestore: listener.onWindowRestore,
        _kWindowEventResize: listener.onWindowResize,
        _kWindowEventResized: listener.onWindowResized,
        _kWindowEventMove: listener.onWindowMove,
        _kWindowEventMoved: listener.onWindowMoved,
        _kWindowEventEnterFullScreen: listener.onWindowEnterFullScreen,
        _kWindowEventLeaveFullScreen: listener.onWindowLeaveFullScreen,
        _kWindowEventDocked: listener.onWindowDocked,
        _kWindowEventUndocked: listener.onWindowUndocked,
      };
      funcMap[eventName]?.call();
    }
  }

  /// ios
  @override
  Future<bool> show() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "show"});
    return data;
  }

  @override
  @override
  Future<void> setBounds(
      {WidgetRect? bounds,
      required double pixelRatio,
      WidgetOffset? position,
      WidgetSize? size,
      bool animate = false}) async {
    final Map<String, dynamic> arguments = {
      "type": "setbounds",
      'devicePixelRatio': pixelRatio,
      'x': bounds?.x ?? position?.x,
      'y': bounds?.y ?? position?.y,
      'width': bounds?.width ?? size?.width,
      'height': bounds?.height ?? size?.height,
      'animate': animate,
    }..removeWhere((key, value) => value == null);
    await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, arguments);
  }

  /// ios
  @override
  Future<bool> init() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "init"});
    return data;
  }

  /// ios
  @override
  Future<bool> isFullScreen() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isFullScreen"});
    return data;
  }

  /// ios
  @override
  Future<bool> isMaximized() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isMaximized"});
    return data;
  }

  /// ios
  @override
  Future<bool> isMinimized() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isMinimized"});
    return data;
  }

  /// ios
  @override
  Future<bool> isVisible() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isVisible"});
    return data;
  }

  /// ios
  @override
  Future<bool> minimize() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "minimize"});
    return data;
  }

  /// ios
  @override
  Future<bool> restore() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "restore"});
    return data;
  }

  /// ios
  @override
  Future<bool> setFullScreen(bool isFullScreen) async {
    final data = await IoPlatformInterface._channel.invokeMethod(
        MrtNativeConst.windowsManager,
        {"type": "restore", "isFullScreen": isFullScreen});
    return data;
  }

  /// ios
  @override
  Future<bool> unmaximize() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "unmaximize"});
    return data;
  }

  /// ios
  @override
  Future<void> waitUntilReadyToShow() async {
    await IoPlatformInterface._channel.invokeMethod(
        MrtNativeConst.windowsManager, {"type": "waitUntilReadyToShow"});
    if (await isFullScreen()) await setFullScreen(false);
    if (await isMaximized()) await unmaximize();
    if (await isMinimized()) await restore();
  }

  /// ios
  @override
  Future<bool> blur() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "blur"});
    return data;
  }

  /// ios
  @override
  Future<bool> close() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "close"});
    return data;
  }

  /// ios
  @override
  Future<bool> focus() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "focus"});
    return data;
  }

  /// ios
  @override
  Future<WidgetRect> getBounds(double pixelRatio) async {
    final Map<String, dynamic> arguments = {
      'devicePixelRatio': pixelRatio,
      'type': 'getBounds'
    };
    final Map<dynamic, dynamic> resultData =
        await IoPlatformInterface._channel.invokeMethod(
      MrtNativeConst.windowsManager,
      arguments,
    );
    return WidgetRect(
      x: resultData['x'],
      y: resultData['y'],
      width: resultData['width'],
      height: resultData['height'],
    );
  }

  /// ios
  @override
  Future<bool> isFocused() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isFocused"});
    return data;
  }

  /// ios
  @override
  Future<bool> isPreventClose() async {
    final data = await IoPlatformInterface._channel.invokeMethod(
        MrtNativeConst.windowsManager, {"type": "isPreventClose"});
    return data;
  }

  /// ios
  @override
  Future<bool> isResizable() async {
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, {"type": "isResizable"});
    return data;
  }

  /// ios
  @override
  Future<bool> setAsFrameless() async {
    final data = await IoPlatformInterface._channel.invokeMethod(
        MrtNativeConst.windowsManager, {"type": "setAsFrameless"});
    return data;
  }

  /// ios
  @override
  Future<bool> setResizable(bool isResizable) async {
    final Map<String, dynamic> arguments = {
      'isResizable': isResizable,
      "type": "setResizable"
    };
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, arguments);
    return data;
  }

  /// minimumSize
  @override
  Future<bool> setMaximumSize(WidgetSize size) async {
    final Map<String, dynamic> arguments = {
      ...size.toJson(),
      "type": "maximumSize"
    };
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, arguments);
    return data;
  }

  @override
  Future<bool> setMinimumSize(WidgetSize size) async {
    final Map<String, dynamic> arguments = {
      ...size.toJson(),
      "type": "minimumSize"
    };
    final data = await IoPlatformInterface._channel
        .invokeMethod(MrtNativeConst.windowsManager, arguments);
    return data;
  }
}
