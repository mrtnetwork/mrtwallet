import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TransactionAmountView extends StatelessWidget {
  const TransactionAmountView({
    super.key,
    required this.amount,
    required this.token,
    this.onTap,
    this.onRemoveIcon,
    this.title,
    this.subtitle,
    this.validate = true,
    this.validateError,
  });
  final BalanceCore? amount;
  final Token token;
  final DynamicVoid? onTap;
  final bool validate;
  final String? validateError;
  final String? subtitle;
  final String? title;
  final Widget? onRemoveIcon;

  @override
  Widget build(BuildContext context) {
    bool hasAmount = amount != null && !amount!.isZero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title ?? "transfer_amount".tr,
            style: context.textTheme.titleMedium),
        if (subtitle != null) LargeTextView([subtitle!.tr], maxLine: 2),
        WidgetConstant.height8,
        ContainerWithBorder(
            validate: hasAmount && validate,
            onRemove: onTap,
            validateText: validateError,
            onRemoveIcon: onRemoveIcon ??
                (hasAmount
                    ? Icon(Icons.edit, color: context.colors.onPrimaryContainer)
                    : Icon(Icons.add,
                        color: context.colors.onPrimaryContainer)),
            child: hasAmount
                ? CoinPriceView(
                    token: token,
                    balance: amount,
                    style: context.textTheme.titleLarge,
                    showTokenImage: true)
                : Text("tap_to_enter_amount".tr))
      ],
    );
  }
}
