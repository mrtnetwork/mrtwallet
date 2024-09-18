import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/stream_bottun.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

import 'animated/widgets/animated_switcher.dart';

class StatusIconWidget extends StatelessWidget {
  const StatusIconWidget({this.onSuccessIcon, super.key, required this.status});
  final StreamWidgetStatus status;
  final Widget? onSuccessIcon;

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(enable: status, widgets: {
      StreamWidgetStatus.success: (c) =>
          onSuccessIcon ?? WidgetConstant.checkCircle,
      StreamWidgetStatus.error: (c) => WidgetConstant.errorIcon,
      StreamWidgetStatus.idle: (c) =>
          Icon(Icons.circle, color: context.colors.transparent),
      StreamWidgetStatus.progress: (c) => const CircularProgressIndicator(),
    });
  }
}
