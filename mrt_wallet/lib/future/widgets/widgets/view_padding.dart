import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ViewPadding extends StatelessWidget {
  const ViewPadding({required this.child, this.padding, super.key});
  final EdgeInsets? padding;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: child,
    );
  }
}

class SliverViewPadding extends StatelessWidget {
  const SliverViewPadding({required this.sliver, this.padding, super.key});
  final EdgeInsets? padding;
  final Widget sliver;
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      sliver: sliver,
    );
  }
}

class BottomPadding extends StatelessWidget {
  const BottomPadding({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final bottom = context.mediaQuery.viewInsets.bottom;
    return Padding(padding: EdgeInsets.only(bottom: bottom), child: child);
  }
}
