import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/core/balance_core.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

class TransactionAmountView extends StatelessWidget {
  const TransactionAmountView(
      {super.key,
      required this.amount,
      required this.token,
      required this.onTap,
      this.validate = true,
      this.validateError});
  final BalanceCore? amount;
  final Token token;
  final DynamicVoid onTap;
  final bool validate;
  final String? validateError;
  @override
  Widget build(BuildContext context) {
    bool hasAmount = amount != null && !amount!.isZero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transaction Amount", style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            validate: hasAmount && validate,
            onRemove: onTap,
            validateText: validateError,
            onRemoveIcon:
                hasAmount ? const Icon(Icons.edit) : const Icon(Icons.add),
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
