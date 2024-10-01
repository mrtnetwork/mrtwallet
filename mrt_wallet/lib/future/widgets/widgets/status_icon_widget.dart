import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/stream_bottun.dart';

import 'animated/widgets/animated_switcher.dart';

class StatusIconWidget extends StatelessWidget {
  const StatusIconWidget(
      {this.onSuccessIcon,
      super.key,
      required this.status,
      this.size = APPConst.double40});
  final StreamWidgetStatus status;
  final Widget? onSuccessIcon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(enable: status, widgets: {
      StreamWidgetStatus.success: (c) =>
          onSuccessIcon ??
          Icon(Icons.check_circle, color: context.colors.green, size: size),
      StreamWidgetStatus.error: (c) =>
          Icon(Icons.error, color: context.colors.error, size: size),
      StreamWidgetStatus.idle: (c) =>
          Icon(Icons.circle, color: context.colors.transparent),
      StreamWidgetStatus.progress: (c) {
        return SizedBox(
            height: size,
            width: size,
            child: const CircularProgressIndicator());
      },
    });
  }
}
