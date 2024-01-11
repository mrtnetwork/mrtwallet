import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("select_output_addresses".tr),
        WidgetConstant.height8,
        ReceiptAddressView(
          title: null,
          subtitle: null,
          validate: controller.receivers.isNotEmpty,
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<BitcoinAddress>>(
                    "receiver_address".tr,
                    child:
                        SelectNetworkAddressView(account: controller.account),
                    maxExtend: 0.8,
                    minExtent: 0.7,
                    initialExtend: 0.7)
                .then(
                  controller.onAddRecever,
                );
          },
          address: null,
        ),
        _OutputSelectedList(
          outputs: controller.receivers,
          onDelete: controller.onAddRecever,
          onBuildTransaction: controller.moveToSend,
        ),
      ],
    );
  }
}

typedef _OnDeleteAddress = void Function(
    ReceiptAddress<BitcoinAddress>? address);

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
            ? WidgetConstant.sizedBox
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(outputs.length, (index) {
                      return ReceiptAddressView(
                        title: null,
                        onEditIcon: const Icon(Icons.remove_circle),
                        subtitle: null,
                        onTap: () {
                          onDelete(outputs[index].address);
                        },
                        address: outputs[index].address,
                      );
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
