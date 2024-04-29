import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/context.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/types/typedef.dart';

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
      this.onTapError});
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
                        color: context.colors.error,
                        width: 2,
                        strokeAlign: 0,
                      )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          color: backgroundColor ?? context.colors.background,
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
