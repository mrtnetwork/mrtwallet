import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/setup_amount.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/models/tron_fee.dart';
import 'package:on_chain/tron/src/models/contract/base_contract/transaction_type.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronFeeDetailsView extends StatelessWidget {
  const TronFeeDetailsView({super.key, required this.transaction});
  final TronTransactionFeeIMpl transaction;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: APPConst.animationDuraion,
      child: _TronTransactionFeeView(
        key: ValueKey(
            "${transaction.loadingFee}/${transaction.consumedFee == null}"),
        transaction: transaction,
      ),
    );
  }
}

class _TronTransactionFeeView extends StatelessWidget {
  const _TronTransactionFeeView({super.key, required this.transaction});
  final TronTransactionFeeIMpl transaction;
  @override
  Widget build(BuildContext context) {
    if (!transaction.loadingFee &&
        transaction.consumedFee == null &&
        transaction.feeCalculationError == null) {
      return WidgetConstant.sizedBox;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("total_burn".tr),
        WidgetConstant.height8,
        transaction.consumedFee == null &&
                transaction.feeCalculationError == null
            ? ContainerWithBorder(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text("retrieving_network_condition".tr)],
              ))
            : transaction.feeCalculationError != null
                ? ContainerWithBorder(
                    backgroundColor: context.colors.errorContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          transaction.feeCalculationError!.tr,
                          style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onErrorContainer),
                        ),
                        WidgetConstant.height8,
                        FilledButton(
                            onPressed: transaction.calculateFee,
                            child: Text("take_another_shot".tr))
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TronFeeInfoWidget(
                          consumedFee: transaction.consumedFee!,
                          network: transaction.network),
                      if (transaction.field.type ==
                          TransactionContractType.triggerSmartContract) ...[
                        WidgetConstant.height20,
                        Text("fee_limit".tr,
                            style: context.textTheme.titleMedium),
                        Text("tron_fee_limit_desc".tr),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          onRemoveIcon: const Icon(Icons.edit),
                          validateText: "low_fee_limit_desc".tr,
                          validate: !transaction.consumedFee!.feeLimitError,
                          onRemove: () {
                            transaction.setCustomFeeLimit(() async {
                              return context.openSliverBottomSheet<BigInt>(
                                "fee_limit".tr,
                                child: SetupNetworkAmount(
                                    token: transaction.network.coinParam.token,
                                    max: transaction
                                        .address.address.currencyBalance,
                                    min: BigInt.zero,
                                    subtitleText: "tron_fee_limit_desc".tr),
                              );
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.consumedFee!.feeLimitType.value.tr,
                                style: context.textTheme.labelLarge,
                              ),
                              CoinPriceView(
                                  token: transaction.network.coinParam.token,
                                  balance: transaction.consumedFee!.feeLimit,
                                  style: context.textTheme.titleLarge),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
        WidgetConstant.height20,
      ],
    );
  }
}

class TronFeeInfoWidget extends StatelessWidget {
  const TronFeeInfoWidget(
      {required this.consumedFee, required this.network, Key? key})
      : super(key: key);
  final TronFee consumedFee;
  final WalletTronNetwork network;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CoinPriceView(
              token: network.coinParam.token,
              balance: consumedFee.totalBurn,
              style: context.textTheme.titleLarge),
        ),
        WidgetConstant.width8,
        ToolTipView(
          mode: TooltipTriggerMode.tap,
          waitDuration: null,
          tooltipWidget: (c) => Container(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "bandwidth".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    RichText(
                        text: TextSpan(
                            style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onTertiaryContainer),
                            children: [
                          TextSpan(
                              text: consumedFee.consumedBandwidth.toString()),
                          const TextSpan(text: "/"),
                          TextSpan(
                              text: consumedFee.stackedBandWidth.toString()),
                        ])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "energy".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    RichText(
                        text: TextSpan(
                            style: context.colors.onTertiaryContainer
                                .bodyMedium(context),
                            children: [
                          TextSpan(
                              text: consumedFee.connsumedEnergy.toString()),
                          const TextSpan(text: "/"),
                          TextSpan(text: consumedFee.stackedEnergy.toString()),
                        ])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "trx_burned_for_resource".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    CoinPriceView(
                        token: network.coinParam.token,
                        balance: consumedFee.burnedForResource,
                        symbolColor: context.colors.onTertiaryContainer,
                        style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.onTertiaryContainer))
                  ],
                ),
                Divider(color: context.colors.onTertiaryContainer),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "total_burn".tr,
                      style: context.textTheme.labelMedium
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                    ),
                    CoinPriceView(
                      token: network.coinParam.token,
                      balance: consumedFee.totalBurn,
                      style: context.textTheme.labelLarge
                          ?.copyWith(color: context.colors.onTertiaryContainer),
                      symbolColor: context.colors.onTertiaryContainer,
                    ),
                  ],
                ),
                Divider(color: context.colors.onTertiaryContainer),
                Text(
                  [
                    "1. Issue a TRC10 token: 1,024 TRX",
                    "2. Apply to be an SR candidate: 9,999 TRX",
                    "3. Create a Bancor transaction: 1,024 TRX",
                    "4. Update the account permission: 100 TRX",
                    "5. Activate the account: 1 TRX",
                    "6. Multi-sig transaction: 1 TRX",
                    "7. Transaction note: 1 TRX"
                  ].join("\n"),
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: context.colors.onTertiaryContainer),
                )
              ],
            ),
          ),
          child: Icon(
            Icons.help,
            color: context.colors.onPrimaryContainer,
          ),
        )
      ],
    ));
  }
}
