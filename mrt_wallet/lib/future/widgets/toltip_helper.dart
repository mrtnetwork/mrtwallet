import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class TooltipHelper extends StatelessWidget {
  const TooltipHelper(this.message,
      {this.iconColor, this.iconSize = AppGlobalConst.double20, Key? key})
      : super(key: key);
  final String message;
  final Color? iconColor;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    return ToolTipView(
        message: message,
        child: Icon(
          Icons.help,
          color: iconColor,
          size: iconSize,
        ));
  }
}
