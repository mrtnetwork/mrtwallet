import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';

class TooltipConstrainsWidget extends StatelessWidget {
  const TooltipConstrainsWidget({required this.child, Key? key})
      : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: APPConst.tooltipConstrainedWidth),
        child: child);
  }
}
