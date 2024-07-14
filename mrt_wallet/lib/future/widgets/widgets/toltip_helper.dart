import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst;

import 'tooltip/widgets/tooltip.dart';

class TooltipHelper extends StatelessWidget {
  const TooltipHelper(this.message,
      {this.iconColor, this.iconSize = APPConst.double20, Key? key})
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
