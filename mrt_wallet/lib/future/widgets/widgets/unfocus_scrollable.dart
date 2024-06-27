import 'package:flutter/material.dart';

class UnfocusableChild extends StatelessWidget {
  const UnfocusableChild(
      {super.key, required this.child, this.cancelBubbling = false});
  final Widget child;
  final bool cancelBubbling;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: NotificationListener<UserScrollNotification>(
        child: child,
        onNotification: (notification) {
          FocusScope.of(context).unfocus();
          return cancelBubbling;
        },
      ),
    );
  }
}
