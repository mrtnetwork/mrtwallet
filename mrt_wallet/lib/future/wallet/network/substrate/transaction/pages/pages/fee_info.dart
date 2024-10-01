import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class SubstrateTransactionFeeView extends StatelessWidget {
  const SubstrateTransactionFeeView(this.controller, {Key? key})
      : super(key: key);
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            validateText: controller.feeError?.tr,
            validate: controller.hasFee,
            onTapWhenOnRemove: false,
            onTapError: () {
              controller.estimateFee();
            },
            onRemove: () {},
            onRemoveIcon: StatusIconWidget(
              status: controller.feeStatus,
              onSuccessIcon: _FeeInfoWidget(
                  feeInfo: controller.feeInfo, network: controller.network),
            ),
            child: CoinPriceView(
              balance: controller.fee,
              token: controller.network.token,
              style: context.textTheme.titleLarge,
              showTokenImage: true,
            )),
      ],
    );
  }
}

class _FeeInfoWidget extends StatelessWidget {
  const _FeeInfoWidget({required this.feeInfo, required this.network, Key? key})
      : super(key: key);
  final SubstrateFeeInfos feeInfo;
  final WalletPolkadotNetwork network;

  @override
  Widget build(BuildContext context) {
    return TappedTooltipView(
        tooltipWidget: ToolTipView(
      tooltipWidget: (c) {
        final Color styleColor = c.colors.onTertiaryContainer;
        final TextStyle textStyle =
            c.textTheme.bodyMedium!.copyWith(color: styleColor);
        final TextStyle coinStyle =
            c.textTheme.labelLarge!.copyWith(color: styleColor);
        return TooltipConstrainsWidget(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("base_fee".tr, style: textStyle),
                CoinPriceView(
                    token: network.token,
                    balance: feeInfo.baseFee,
                    symbolColor: styleColor,
                    style: coinStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("len_fee".tr, style: textStyle),
                CoinPriceView(
                    token: network.token,
                    balance: feeInfo.lenFee,
                    symbolColor: styleColor,
                    style: coinStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("weight_fee".tr, style: textStyle),
                CoinPriceView(
                    token: network.token,
                    balance: feeInfo.adjustedWeightFee,
                    symbolColor: styleColor,
                    style: coinStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("tip".tr, style: textStyle),
                CoinPriceView(
                    token: network.token,
                    balance: feeInfo.tip,
                    symbolColor: styleColor,
                    style: coinStyle)
              ],
            ),
            Divider(color: styleColor),
            CoinPriceView(
                token: network.token,
                balance: feeInfo.total,
                symbolColor: styleColor,
                style: c.textTheme.titleLarge!.copyWith(color: styleColor))
          ],
        ));
      },
      child: const Icon(Icons.info),
    ));
  }
}
