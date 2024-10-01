import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class StellarTransactionFeeView extends StatelessWidget {
  const StellarTransactionFeeView(this.controller, {Key? key})
      : super(key: key);
  final StellarTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        onRemove: () {
          context
              .openSliverBottomSheet<(String?, BigInt?)>(
            "transaction_fee".tr,
            child: SetupTransactionFee(
              fees: controller.fees,
              network: controller.network,
              type: controller.feeMode.name,
              max: controller.maximumFee,
              customFee: controller.fee?.balance,
            ),
          )
              .then((value) {
            controller.setFee(value?.$1, customFee: value?.$2);
          });
        },
        onRemoveIcon: const Icon(Icons.edit),
        child: APPAnimatedSwitcher(
            width: context.mediaQuery.size.width,
            enable: controller.hasFee,
            widgets: {
              false: (c) => Text("estimating_fee_please_wait".tr,
                  style: context.colors.onPrimaryContainer.bodyMedium(context)),
              true: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.feeMode.name.camelCase,
                          style: context.colors.onPrimaryContainer
                              .lableLarge(context)),
                      CoinPriceView(
                          token: controller.network.coinParam.token,
                          balance: controller.fee,
                          style: context.colors.onPrimaryContainer
                              .titleLarge(context)),
                      ErrorTextContainer(
                        verticalMargin: WidgetConstant.paddingVertical10,
                        error: controller.feeError,
                      ),
                    ],
                  ),
            }));
  }
}
