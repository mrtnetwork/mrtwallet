import 'package:flutter/material.dart'
    show GlobalKey, Scrollable, Curves, Rect, RenderBox, Offset;
import 'package:mrt_wallet/app/models/models/typedef.dart';

extension QuickWidgetKeys on GlobalKey {
  void ensureKeyVisible(
      {int afterMilliseconds = 400,
      int jumpDuration = 320,
      double alignment = 0.5,
      DynamicVoid? onScroll}) async {
    await Future.delayed(Duration(milliseconds: afterMilliseconds));
    try {
      if (currentContext?.mounted ?? false) {
        await Scrollable.ensureVisible(currentContext!,
            alignment: alignment,
            duration: Duration(milliseconds: jumpDuration),
            curve: Curves.decelerate);
        onScroll?.call();
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Rect? getPosition() {
    try {
      final RenderBox renderBox =
          currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    } catch (e) {
      return null;
    }
  }
}
