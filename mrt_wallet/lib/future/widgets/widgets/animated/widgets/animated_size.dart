import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/typdef/typedef.dart';

class APPAnimatedSize extends StatelessWidget {
  const APPAnimatedSize(
      {required this.isActive,
      required this.onActive,
      required this.onDeactive,
      this.duration = APPConst.animationDuraion,
      this.alignment = Alignment.topCenter,
      super.key});
  final bool isActive;
  final WidgetContextNullable onActive;
  final WidgetContextNullable onDeactive;
  final Duration duration;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      alignment: alignment,
      child: isActive ? onActive(context) : onDeactive(context),
    );
  }
}
