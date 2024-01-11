import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/resource_v2/freez_balance_v2.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class TronFreezBalanceV2FieldsView extends StatelessWidget {
  const TronFreezBalanceV2FieldsView(
      {required this.account,
      required this.address,
      required this.validator,
      super.key});
  final CryptoAccountAddress address;
  final NetworkAccountCore account;
  final TronFreezBalanceV2Validator validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("resource".tr, style: context.textTheme.titleMedium),
        Text("trx_stake_type".tr),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: {
            for (final i in TronUtils.tronFrozenReosurce)
              i: Text(i.name.toLowerCase().camelCase)
          },
          label: "resource".tr,
          onChanged: (p0) {
            validator.setValue(validator.resource, p0);
          },
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: validator.amount.value,
          subtitle: "trx_stake_amount".tr,
          title: "frozen_balance".tr,
          validate: validator.amount.isCompleted,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
              "frozen_balance".tr,
              child: SetupNetworkAmount(
                token: account.network.coinParam.token,
                max: account.address.address.balance.value.balance,
                min: BigInt.zero,
                subtitleText: "trx_stake_amount".tr,
              ),
            )
                .then((value) {
              if (value == null) {
                validator.setValue(validator.amount, null);
              } else {
                validator.setValue(
                    validator.amount,
                    NoneDecimalBalance(
                        value, account.network.coinParam.token.decimal!));
              }
            });
          },
          token: account.network.coinParam.token,
        ),
      ],
    );
  }
}
