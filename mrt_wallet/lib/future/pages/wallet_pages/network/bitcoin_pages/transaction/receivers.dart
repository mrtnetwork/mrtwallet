import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';

class BitcoinTransactionReceiverView extends StatelessWidget {
  const BitcoinTransactionReceiverView({super.key, required this.controller});
  final BitcoinStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "recipients".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("select_output_addresses".tr),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton.icon(
                        padding: WidgetConstant.paddingVertical20,
                        onPressed: () {
                          context
                              .openSliverBottomSheet<BitcoinAddress>(
                                  SelectAddress(network: controller.network),
                                  "receiver_address".tr,
                                  maxExtend: 0.8,
                                  minExtent: 0.7,
                                  initialExtend: 0.7)
                              .then(controller.onAddRecever);
                        },
                        icon: const Icon(Icons.add),
                        label: Text("tap_to_select".tr))
                  ],
                )
              ],
            )),
        _OutputSelectedList(
          outputs: controller.receivers,
          onDelete: controller.onAddRecever,
          onBuildTransaction: controller.moveToSend,
        ),
      ],
    );
  }
}

typedef _OnDeleteAddress = void Function(BitcoinAddress? address);

class _OutputSelectedList extends StatelessWidget {
  const _OutputSelectedList(
      {required this.outputs,
      required this.onDelete,
      required this.onBuildTransaction});
  final List<BitcoinOutputWithBalance> outputs;
  final _OnDeleteAddress onDelete;
  final DynamicVoid onBuildTransaction;
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: AppGlobalConst.animationDuraion,
        child: outputs.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("list_of_recipients".tr,
                      style: context.textTheme.titleLarge),
                  WidgetConstant.height8,
                  Column(
                    children: List.generate(outputs.length, (index) {
                      return ContainerWithBorder(
                          onRemove: () {
                            onDelete(outputs[index].address);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                outputs[index].address.type.value,
                                style: context.textTheme.labelLarge,
                              ),
                              OneLineTextWidget(
                                outputs[index].viewAddress,
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ));
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical20,
                        onPressed: onBuildTransaction,
                        child: Text("build_transaction".tr),
                      )
                    ],
                  )
                ],
              ));
  }
}
