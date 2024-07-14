import 'package:flutter/material.dart';

class APPPreferredSizeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const APPPreferredSizeWidget(
      {super.key, required this.child, required this.height});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
