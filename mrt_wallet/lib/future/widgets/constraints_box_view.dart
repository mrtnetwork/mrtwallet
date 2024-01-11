import 'package:flutter/material.dart';

class ConstraintsBoxView extends StatelessWidget {
  final Widget child;
  const ConstraintsBoxView(
      {required this.child,
      this.maxWidth = 650,
      this.maxHeight = double.infinity,
      this.alignment = Alignment.topCenter,
      super.key,
      this.padding = EdgeInsets.zero});
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
