import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/app_extensions/context.dart'
    show QuickContextAccsess;
import 'package:mrt_wallet/app/models/models/typedef.dart';

import 'error_text_container.dart';
import 'widget_constant.dart';

class ContainerWithBorder extends StatelessWidget {
  const ContainerWithBorder(
      {super.key,
      required this.child,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.onRemove,
      this.borderRadius,
      this.backgroundColor,
      this.onRemoveWidget,
      this.onRemoveIcon,
      this.validate = true,
      this.validateText,
      this.shadow = false,
      this.onTapWhenOnRemove = true,
      this.iconAlginment = CrossAxisAlignment.center,
      this.onTapError,
      this.constraints = WidgetConstant.constraintsMinHeight60});
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final DynamicVoid? onRemove;
  final Widget? onRemoveWidget;
  final Widget? onRemoveIcon;
  final bool validate;
  final String? validateText;
  final bool shadow;
  final bool onTapWhenOnRemove;
  final CrossAxisAlignment iconAlginment;
  final DynamicVoid? onTapError;
  final BoxConstraints? constraints;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: borderRadius ?? WidgetConstant.border8,
          onTap: onTapWhenOnRemove ? onRemove : null,
          child: Container(
            padding: padding,
            margin: margin,
            constraints: constraints,
            decoration: BoxDecoration(
                color: backgroundColor ?? context.colors.primaryContainer,
                borderRadius: borderRadius ?? WidgetConstant.border8,
                boxShadow: !shadow
                    ? null
                    : [
                        BoxShadow(
                            color: context.colors.shadow,
                            blurRadius: 4,
                            spreadRadius: 0.2)
                      ],
                border: validate
                    ? null
                    : Border.all(
                        color: context.colors.errorContainer,
                        width: 2,
                        strokeAlign: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: iconAlginment,
                  children: [
                    Expanded(child: child),
                    if (onRemove != null)
                      Row(
                        children: [
                          WidgetConstant.width8,
                          onRemoveWidget ??
                              IconButton(
                                  onPressed: onRemove,
                                  icon: onRemoveIcon ??
                                      const Icon(Icons.remove_circle))
                        ],
                      )
                  ],
                ),
                if (!validate && validateText != null)
                  ErrorTextContainer(
                    error: validateText ?? "",
                    margin: WidgetConstant.padding5,
                    padding: WidgetConstant.padding5,
                    oTapError: onTapError,
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ContainerWithCheckBoxAndBorder extends StatelessWidget {
  const ContainerWithCheckBoxAndBorder({
    super.key,
    required this.child,
    required this.onChange,
    required this.value,
    this.padding = WidgetConstant.padding10,
    this.margin = WidgetConstant.padding5,
    this.borderRadius,
    this.backgroundColor,
  });
  final bool value;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final NullBoolVoid? onChange;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChange == null
          ? null
          : () {
              onChange?.call(!value);
            },
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surface,
          borderRadius: borderRadius ?? WidgetConstant.border8,
        ),
        child: Row(
          children: [
            Expanded(child: child),
            Row(
              children: [
                WidgetConstant.width8,
                Checkbox(value: value, onChanged: onChange)
              ],
            )
          ],
        ),
      ),
    );
  }
}
