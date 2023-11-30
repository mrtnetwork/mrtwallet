import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';

class ProviderTrackerStatusView extends StatelessWidget {
  const ProviderTrackerStatusView({super.key, required this.provider});
  final ApiProviderTracker provider;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() => ToolTipView(
        message: provider.toString().tr,
        child: Icon(
          Icons.circle,
          color: provider.hasActive ? CustomColors.green : context.colors.error,
        )));
  }
}
