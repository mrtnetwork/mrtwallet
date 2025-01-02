import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/typdef/typedef.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

class ConditionalWidgets<T> extends StatelessWidget {
  const ConditionalWidgets(
      {required this.enable, required this.widgets, super.key});
  final T? enable;
  final Map<T?, WidgetContext> widgets;

  @override
  Widget build(BuildContext context) {
    return _Wrap(widgets[enable]?.call(context) ?? WidgetConstant.sizedBox,
        key: ValueKey<T?>(enable));
  }
}

class ConditionalWidget extends StatelessWidget {
  const ConditionalWidget(
      {required this.onActive, this.onDeactive, this.enable = true, super.key});
  final WidgetContext onActive;
  final WidgetContext? onDeactive;
  final bool enable;
  @override
  Widget build(BuildContext context) {
    return ConditionalWidgets(enable: enable, widgets: {
      true: (context) => onActive(context),
      false: (context) => onDeactive?.call(context) ?? WidgetConstant.sizedBox
    });
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap(this.widget, {super.key});
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}
