import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart' show DynamicVoid;

class FixedElevatedButton extends StatelessWidget {
  const FixedElevatedButton({
    required this.child,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
    this.focusNode,
    super.key,
  }) : icon = null;
  const FixedElevatedButton.icon({
    required Widget label,
    required this.onPressed,
    required Icon this.icon,
    this.padding = EdgeInsets.zero,
    this.focusNode,
    super.key,
  }) : child = label;
  final Widget child;
  final DynamicVoid? onPressed;
  final EdgeInsets padding;
  final Icon? icon;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: icon != null
            ? ElevatedButton.icon(
                focusNode: focusNode,
                onPressed: onPressed,
                autofocus: true,
                icon: icon!,
                label: child)
            : ElevatedButton(
                onPressed: onPressed,
                focusNode: focusNode,
                autofocus: true,
                child: child,
              ));
  }
}
