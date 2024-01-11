import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/setup_amount.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:on_chain/tron/models/contract/base_contract/transaction_type.dart';

class TronFeeDetailsView extends StatelessWidget {
  const TronFeeDetailsView({super.key, required this.transaction});
  final TronTransactionFeeIMpl transaction;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppGlobalConst.animationDuraion,
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
                      ContainerWithBorder(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CoinPriceView(
                                token: transaction.network.coinParam.token,
                                balance: transaction.consumedFee!.totalBurn,
                                style: context.textTheme.titleLarge),
                          ),
                          Text(
                            "burn".tr.toUpperCase(),
                            style: context.textTheme.labelLarge
                                ?.copyWith(color: context.colors.error),
                          ),
                          WidgetConstant.width8,
                          ToolTipView(
                            mode: TooltipTriggerMode.tap,
                            waitDuration: null,
                            tooltipWidget: Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "bandwidth".tr,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onTertiary),
                                      ),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: transaction
                                                .consumedFee!.consumedBandwidth
                                                .toString()),
                                        const TextSpan(text: "/"),
                                        TextSpan(
                                            text: transaction
                                                .consumedFee!.stackedBandWidth
                                                .toString()),
                                      ])),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "energy".tr,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onTertiary),
                                      ),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: transaction
                                                .consumedFee!.connsumedEnergy
                                                .toString()),
                                        const TextSpan(text: "/"),
                                        TextSpan(
                                            text: transaction
                                                .consumedFee!.stackedEnergy
                                                .toString()),
                                      ])),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "trx_burned_for_resource".tr,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onTertiary),
                                      ),
                                      CoinPriceView(
                                          token: transaction
                                              .network.coinParam.token,
                                          balance: transaction
                                              .consumedFee!.burnedForResource,
                                          symbolColor:
                                              context.colors.onTertiary,
                                          style: context.textTheme.labelLarge
                                              ?.copyWith(
                                                  color: context
                                                      .colors.onTertiary))
                                    ],
                                  ),
                                  Divider(color: context.colors.onTertiary),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "total_burn".tr,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                                color:
                                                    context.colors.onTertiary),
                                      ),
                                      CoinPriceView(
                                        token:
                                            transaction.network.coinParam.token,
                                        balance:
                                            transaction.consumedFee!.totalBurn,
                                        style: context.textTheme.labelLarge
                                            ?.copyWith(
                                                color:
                                                    context.colors.onTertiary),
                                        symbolColor: context.colors.onTertiary,
                                      ),
                                      ToolTipView(
                                        waitDuration: null,
                                        tooltipWidget: Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 300),
                                          child: Text(
                                            '''Fees paid by transaction senders/sending addresses:
1. Issue a TRC10 token: 1,024 TRX
2. Apply to be an SR candidate: 9,999 TRX
3. Create a Bancor transaction: 1,024 TRX
4. Update the account permission: 100 TRX
5. Activate the account: 1 TRX
6. Multi-sig transaction: 1 TRX
7. Transaction note: 1 TRX''',
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                                    color: context
                                                        .colors.onTertiary),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.help,
                                          color: context.colors.onTertiary,
                                          size: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.help),
                          )
                        ],
                      )),
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
                                        .address.address.balance.value.balance,
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
