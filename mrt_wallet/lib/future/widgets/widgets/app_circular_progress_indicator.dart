import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

class APPCircularProgressIndicator extends StatelessWidget {
  const APPCircularProgressIndicator(
      {super.key,
      this.color,
      this.size = WidgetConstant.circularProgressIndicatorSize});
  final Color? color;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
        size: size, child: CircularProgressIndicator(color: color));
  }
}
