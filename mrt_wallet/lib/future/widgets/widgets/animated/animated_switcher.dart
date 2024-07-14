import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/sliver/widgets/animated_switcher.dart';
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

class APPSliverAnimatedSwitcher<T> extends StatelessWidget {
  const APPSliverAnimatedSwitcher(
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
    return SliverAnimatedSwitcher(
      duration: duration,
      child: _Wrap(widgets[enable]?.call(context) ?? const SliverToBoxAdapter(),
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
