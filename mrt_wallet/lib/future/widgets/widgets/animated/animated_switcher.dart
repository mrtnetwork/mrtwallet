import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

class APPAnimatedSwitcher<T> extends StatelessWidget {
  const APPAnimatedSwitcher(
      {required this.enable,
      required this.widgets,
      this.duration = APPConst.animationDuraion,
      Key? key})
      : super(key: key);
  final T? enable;
  final Map<T?, WidgetContext> widgets;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: _Wrap(widgets[enable]?.call(context) ?? WidgetConstant.sizedBox,
          key: ValueKey<T?>(enable)),
    );
  }
}

class APPAnimatedSwitcherTest<T> extends StatelessWidget {
  const APPAnimatedSwitcherTest(
      {required this.enable,
      required this.widgets,
      this.duration = APPConst.animationDuraion,
      Key? key})
      : super(key: key);
  final T? enable;
  final Map<T?, Widget> widgets;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: _Wrap(widgets[enable] ?? WidgetConstant.sizedBox,
          key: ValueKey<T?>(enable)),
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap(this.widget, {Key? key}) : super(key: key);
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}
