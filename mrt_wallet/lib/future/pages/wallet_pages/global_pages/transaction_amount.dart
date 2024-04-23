import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

class TransactionAmountView extends StatelessWidget {
  const TransactionAmountView(
      {super.key,
      required this.amount,
      required this.token,
      required this.onTap,
      this.onRemoveIcon,
      this.title,
      this.subtitle,
      this.validate = true,
      this.validateError});
  final BalanceCore? amount;
  final Token token;
  final DynamicVoid onTap;
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
        Text(title ?? "Transaction Amount",
            style: context.textTheme.titleMedium),
        if (subtitle != null) Text(subtitle!.tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            validate: hasAmount && validate,
            onRemove: onTap,
            validateText: validateError,
            onRemoveIcon: onRemoveIcon ??
                (hasAmount ? const Icon(Icons.edit) : const Icon(Icons.add)),
            child: hasAmount
                ? CoinPriceView(
                    token: token,
                    balance: amount,
                    style: context.textTheme.titleLarge)
                : Text("tap_to_enter_amount".tr))
      ],
    );
  }
}
