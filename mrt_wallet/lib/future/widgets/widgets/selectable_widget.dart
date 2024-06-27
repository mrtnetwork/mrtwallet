import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show QuickContextAccsess, Translate;

class SelectableView extends StatelessWidget {
  const SelectableView({super.key, this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text ?? "selected".tr,
        style: context.textTheme.labelSmall
            ?.copyWith(color: context.colors.onTertiaryContainer),
      ),
      backgroundColor: context.colors.tertiaryContainer,
      padding: EdgeInsets.zero,
    );
  }
}
