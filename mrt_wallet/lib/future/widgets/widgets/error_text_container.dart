import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst;
import 'package:mrt_wallet/app/models/models/typedef.dart' show DynamicVoid;
import 'package:mrt_wallet/wallet/wallet.dart' show BalanceCore, Token;
import 'container_with_border.dart';
import 'widget_constant.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ErrorTextContainer extends StatelessWidget {
  const ErrorTextContainer(
      {super.key,
      required this.error,
      this.errorIcon = const Icon(Icons.error),
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.verticalMargin = EdgeInsets.zero,
      this.showErrorIcon = true,
      this.oTapError});
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? error;
  final EdgeInsets verticalMargin;
  final bool showErrorIcon;
  final DynamicVoid? oTapError;
  final Icon errorIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: APPConst.animationDuraion,
      child: error == null
          ? WidgetConstant.sizedBox
          : Padding(
              padding: verticalMargin,
              child: ContainerWithBorder(
                onRemove: showErrorIcon
                    ? () {
                        oTapError?.call();
                      }
                    : null,
                margin: margin,
                padding: padding,
                onRemoveIcon: errorIcon,
                backgroundColor: context.colors.errorContainer,
                child: Text(
                  error ?? "",
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: context.colors.onErrorContainer),
                ),
              ),
            ),
    );
  }
}

class InsufficientBalanceErrorView extends StatelessWidget {
  const InsufficientBalanceErrorView(
      {required this.balance,
      required this.token,
      super.key,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.verticalMargin = EdgeInsets.zero});
  final BalanceCore balance;
  final Token token;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final EdgeInsets verticalMargin;

  @override
  Widget build(BuildContext context) {
    if (!balance.isNegative) return WidgetConstant.sizedBox;
    final String absBalance = balance.price.replaceFirst("-", "");
    return Padding(
      padding: verticalMargin,
      child: ContainerWithBorder(
          onRemove: () {},
          margin: margin,
          padding: padding,
          onRemoveIcon: const Icon(Icons.error),
          backgroundColor: context.colors.errorContainer,
          child: Text(
            "insufficient_balance_error".tr.replaceOne(
                  "$absBalance ${token.symbol}",
                ),
            style: context.textTheme.labelMedium
                ?.copyWith(color: context.colors.onErrorContainer),
          )),
    );
  }
}
