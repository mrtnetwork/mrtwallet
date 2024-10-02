import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/widgets/sliver/sliver.dart';

class ConstraintsBoxView extends StatelessWidget {
  final Widget child;
  const ConstraintsBoxView(
      {required this.child,
      this.maxWidth = 650,
      this.maxHeight = double.infinity,
      this.alignment = Alignment.topCenter,
      super.key,
      this.padding = EdgeInsets.zero});
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets padding;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class SliverConstraintsBoxView extends StatelessWidget {
  final Widget sliver;
  const SliverConstraintsBoxView(
      {required this.sliver,
      this.maxWidth = 650,
      super.key,
      this.padding = EdgeInsets.zero,
      this.alignment = 0});
  final double? maxWidth;
  final EdgeInsets padding;
  final double alignment;
  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisConstrained(
      alignment: alignment,
      maxCrossAxisExtent: maxWidth ?? context.mediaQuery.size.width,
      child: SliverPadding(padding: padding, sliver: sliver),
    );
  }
}
