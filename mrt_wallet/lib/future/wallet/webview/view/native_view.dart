import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mrt_native_support/models/device/models/platform.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';

class MRTAndroidViewController<T> {
  final T controller;
  final int id;
  final String viewType;
  DynamicVoid? onFocus;
  final FocusNode node;
  MRTAndroidViewController(
      {required this.controller,
      required this.id,
      required this.node,
      required this.viewType});
  static Future<MRTAndroidViewController> create(
      {required String viewType,
      Map<String, String> createParms = const {},
      TextDirection layoutDirection = TextDirection.ltr}) async {
    final id = Random.secure().nextInt(100) + 50;
    final node = FocusNode(debugLabel: "MRTAndroidViewController $id");
    Object controller;

    if (PlatformInterface.appPlatform == AppPlatform.android) {
      controller = PlatformViewsService.initAndroidView(
        id: id,
        viewType: viewType,
        layoutDirection: layoutDirection,
        creationParams: createParms,
        creationParamsCodec: const StandardMessageCodec(),
        onFocus: () {
          node.requestFocus();
        },
      );
    } else {
      controller = await PlatformViewsService.initUiKitView(
        id: id,
        viewType: viewType,
        layoutDirection: layoutDirection,
        creationParams: createParms,
        creationParamsCodec: const StandardMessageCodec(),
        onFocus: () {
          node.requestFocus();
        },
      );
    }
    return MRTAndroidViewController(
        controller: controller, id: id, node: node, viewType: viewType);
  }

  Future<void> dispose() async {
    if (PlatformInterface.appPlatform == AppPlatform.android) {
      await (controller as AndroidViewController).dispose();
    } else {
      await PlatformInterface.webViewController.dispose(viewType);
      await (controller as UiKitViewController).dispose();
    }

    node.dispose();
  }
}

class APPNativeView extends StatefulWidget {
  const APPNativeView(
      {super.key,
      required this.controller,
      this.onPlatformViewCreated,
      this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
      this.gestureRecognizers,
      this.clipBehavior = Clip.hardEdge,
      this.creationParamsCodec});
  final PlatformViewCreatedCallback? onPlatformViewCreated;
  final MRTAndroidViewController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final MessageCodec<dynamic>? creationParamsCodec;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final Clip clipBehavior;

  @override
  // ignore: no_logic_in_create_state
  State<APPNativeView> createState() {
    if (PlatformInterface.appPlatform == AppPlatform.android) {
      return _AndroidViewState();
    }
    return _UiKitViewState();
  }
}

class _AndroidViewState extends State<APPNativeView> {
  late final MRTAndroidViewController controller = widget.controller;
  TextDirection _layoutDirection = TextDirection.ltr;
  AndroidViewController get _controller => controller.controller;

  bool _initialized = false;
  FocusNode get _focusNode => controller.node;

  static final Set<Factory<OneSequenceGestureRecognizer>> _emptyRecognizersSet =
      <Factory<OneSequenceGestureRecognizer>>{};

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChange,
      child: _AndroidPlatformView(
        controller: _controller,
        hitTestBehavior: widget.hitTestBehavior,
        gestureRecognizers: widget.gestureRecognizers ?? _emptyRecognizersSet,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;
    if (didChangeLayoutDirection || !_initialized) {
      _initialized = true;
      // The native view will update asynchronously, in the meantime we don't want
      // to block the framework. (so this is intentionally not awaiting).
      _controller.setLayoutDirection(_layoutDirection);
    }
  }

  @override
  void didUpdateWidget(APPNativeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    if (didChangeLayoutDirection) {
      _controller.setLayoutDirection(_layoutDirection);
    }
  }

  TextDirection _findLayoutDirection() {
    assert(debugCheckHasDirectionality(context));
    return Directionality.of(context);
  }

  void _onFocusChange(bool isFocused) {
    if (!_controller.isCreated) {
      return;
    }
    if (!isFocused) {
      _controller.clearFocus().catchError((dynamic e) {
        if (e is MissingPluginException) {
          return;
        }
      });
      return;
    }
    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.setPlatformViewClient',
      <String, dynamic>{'platformViewId': controller.id},
    ).catchError((dynamic e) {
      if (e is MissingPluginException) {
        return;
      }
    });
  }
}

class _AndroidPlatformView extends LeafRenderObjectWidget {
  const _AndroidPlatformView({
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
    this.clipBehavior = Clip.hardEdge,
  });

  final AndroidViewController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAndroidView(
        viewController: controller,
        hitTestBehavior: hitTestBehavior,
        gestureRecognizers: gestureRecognizers,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderAndroidView renderObject) {
    renderObject.controller = controller;
    renderObject.hitTestBehavior = hitTestBehavior;
    renderObject.updateGestureRecognizers(gestureRecognizers);
    renderObject.clipBehavior = clipBehavior;
  }
}

abstract class _DarwinViewState<
    PlatformViewT extends APPNativeView,
    RenderT extends RenderDarwinPlatformView,
    ViewT extends _DarwinPlatformView<DarwinPlatformViewController,
        RenderT>> extends State<PlatformViewT> {
  UiKitViewController get controller =>
      widget.controller.controller as UiKitViewController;
  TextDirection? _layoutDirection;

  FocusNode get focusNode => widget.controller.node;

  static final Set<Factory<OneSequenceGestureRecognizer>> _emptyRecognizersSet =
      <Factory<OneSequenceGestureRecognizer>>{};

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: focusNode,
        onFocusChange: (bool isFocused) =>
            _onFocusChange(isFocused, controller),
        child: childPlatformView());
  }

  ViewT childPlatformView();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;
    if (didChangeLayoutDirection) {
      // The native view will update asynchronously, in the meantime we don't want
      // to block the framework. (so this is intentionally not awaiting).
      controller.setLayoutDirection(_layoutDirection!);
    }
  }

  @override
  void didUpdateWidget(PlatformViewT oldWidget) {
    super.didUpdateWidget(oldWidget);

    final TextDirection newLayoutDirection = _findLayoutDirection();
    final bool didChangeLayoutDirection =
        _layoutDirection != newLayoutDirection;
    _layoutDirection = newLayoutDirection;

    if (didChangeLayoutDirection) {
      controller.setLayoutDirection(_layoutDirection ?? TextDirection.ltr);
    }
  }

  TextDirection _findLayoutDirection() {
    assert(debugCheckHasDirectionality(context));
    return Directionality.of(context);
  }

  void _onFocusChange(bool isFocused, DarwinPlatformViewController controller) {
    if (!isFocused) {
      return;
    }
    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.setPlatformViewClient',
      <String, dynamic>{'platformViewId': controller.id},
    );
  }
}

class _UiKitViewState extends _DarwinViewState<APPNativeView, RenderUiKitView,
    _UiKitPlatformView> {
  @override
  _UiKitPlatformView childPlatformView() {
    return _UiKitPlatformView(
      controller: controller,
      hitTestBehavior: widget.hitTestBehavior,
      gestureRecognizers:
          widget.gestureRecognizers ?? _DarwinViewState._emptyRecognizersSet,
    );
  }
}

abstract class _DarwinPlatformView<
        TController extends DarwinPlatformViewController,
        TRender extends RenderDarwinPlatformView<TController>>
    extends LeafRenderObjectWidget {
  const _DarwinPlatformView({
    required this.controller,
    required this.hitTestBehavior,
    required this.gestureRecognizers,
  });

  final TController controller;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  @mustCallSuper
  void updateRenderObject(BuildContext context, TRender renderObject) {
    renderObject
      ..viewController = controller
      ..hitTestBehavior = hitTestBehavior
      ..updateGestureRecognizers(gestureRecognizers);
  }
}

class _UiKitPlatformView
    extends _DarwinPlatformView<UiKitViewController, RenderUiKitView> {
  const _UiKitPlatformView(
      {required super.controller,
      required super.hitTestBehavior,
      required super.gestureRecognizers});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderUiKitView(
      viewController: controller,
      hitTestBehavior: hitTestBehavior,
      gestureRecognizers: gestureRecognizers,
    );
  }
}
