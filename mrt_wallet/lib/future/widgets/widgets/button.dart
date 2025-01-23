import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart' show DynamicVoid;

class FixedElevatedButton extends StatelessWidget {
  const FixedElevatedButton({
    required this.onPressed,
    required this.child,
    this.activePress,
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
    this.activePress,
    super.key,
  }) : child = label;
  final DynamicVoid? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final Icon? icon;
  final FocusNode? focusNode;
  final bool? activePress;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: icon != null
            ? ElevatedButton.icon(
                focusNode: focusNode,
                onPressed: (activePress ?? true) ? onPressed : null,
                autofocus: true,
                icon: icon!,
                label: child)
            : ElevatedButton(
                onPressed: (activePress ?? true) ? onPressed : null,
                focusNode: focusNode,
                autofocus: true,
                child: child,
              ));
  }
}
