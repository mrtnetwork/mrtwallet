import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst;
import 'package:mrt_wallet/app/models/models/typedef.dart' show DynamicVoid;
import 'container_with_border.dart';
import 'widget_constant.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class AlarmTextContainer extends StatelessWidget {
  const AlarmTextContainer(
      {super.key,
      required this.message,
      this.icon,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.verticalMargin = EdgeInsets.zero,
      this.showIcon = true,
      this.onTap,
      this.enableTap = true});
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? message;
  final EdgeInsets verticalMargin;
  final bool showIcon;
  final DynamicVoid? onTap;
  final IconData? icon;
  final bool enableTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: APPConst.animationDuraion,
      child: message == null
          ? WidgetConstant.sizedBox
          : Padding(
              padding: verticalMargin,
              child: ContainerWithBorder(
                constraints: null,
                enableTap: enableTap,
                onRemove: showIcon
                    ? () {
                        onTap?.call();
                      }
                    : null,
                margin: margin,
                padding: padding,
                onRemoveIcon: Icon(icon ?? Icons.error,
                    color: context.colors.onTertiaryContainer),
                backgroundColor: context.colors.tertiaryContainer,
                child: Text(
                  message ?? "",
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: context.colors.onTertiaryContainer),
                ),
              ),
            ),
    );
  }
}
