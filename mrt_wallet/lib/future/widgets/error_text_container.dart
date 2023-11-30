import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/extention/context.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class ErrorTextContainer extends StatelessWidget {
  const ErrorTextContainer({
    super.key,
    required this.error,
    this.padding = WidgetConstant.padding10,
    this.margin = WidgetConstant.padding5,
  });
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) return WidgetConstant.sizedBox;
    return ContainerWithBorder(
      onRemove: () {},
      margin: margin,
      padding: padding,
      onRemoveIcon: const Icon(Icons.error),
      backgroundColor: context.colors.errorContainer,
      child: Text(
        error ?? "",
        style: context.textTheme.labelMedium
            ?.copyWith(color: context.colors.onErrorContainer),
      ),
    );
  }
}
