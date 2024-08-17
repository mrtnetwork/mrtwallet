// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';

class MRTAndroidView extends StatefulWidget {
  const MRTAndroidView(
      {super.key,
      required this.controller,
      this.onPlatformViewCreated,
      this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
      this.gestureRecognizers,
      this.clipBehavior = Clip.hardEdge});
  final MRTAndroidViewController controller;

  final PlatformViewCreatedCallback? onPlatformViewCreated;

  final PlatformViewHitTestBehavior hitTestBehavior;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final Clip clipBehavior;

  @override
  State<MRTAndroidView> createState() => _AndroidViewState();
}

class MRTAndroidViewController {
  final AndroidViewController controller;
  final int id;
  DynamicVoid? onFocus;
  final FocusNode node;
  MRTAndroidViewController(
      {required this.controller, required this.id, required this.node});
  factory MRTAndroidViewController.create(
      {required String viewType,
      Map<String, String> createParms = const {},
      TextDirection layoutDirection = TextDirection.ltr}) {
    final id = platformViewsRegistry.getNextPlatformViewId();
    final node = FocusNode(debugLabel: "MRTAndroidViewController $id");
    final controller = PlatformViewsService.initAndroidView(
      id: id,
      viewType: viewType,
      layoutDirection: layoutDirection,
      creationParams: createParms,
      creationParamsCodec: const StandardMessageCodec(),
      onFocus: () {
        node.requestFocus();
      },
    );
    return MRTAndroidViewController(controller: controller, id: id, node: node);
  }
  void dispose() {
    controller.dispose();
    node.dispose();
  }
}

class _AndroidViewState extends State<MRTAndroidView> {
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
  void didUpdateWidget(MRTAndroidView oldWidget) {
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

  @override
  void dispose() {
    super.dispose();
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

// extension on PlatformViewController {
//   /// Disposes the controller in a post-frame callback, to allow other widgets to
//   /// remove their listeners before the controller is disposed.
//   void disposePostFrame() {
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       dispose();
//     }, debugLabel: 'PlatformViewController.dispose');
//   }
// }
