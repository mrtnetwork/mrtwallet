import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class ErrorTextContainer extends StatelessWidget {
  const ErrorTextContainer(
      {super.key,
      required this.error,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.verticalMargin = EdgeInsets.zero});
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? error;
  final EdgeInsets verticalMargin;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: AppGlobalConst.animationDuraion,
      child: error == null
          ? WidgetConstant.sizedBox
          : Padding(
              padding: verticalMargin,
              child: ContainerWithBorder(
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
