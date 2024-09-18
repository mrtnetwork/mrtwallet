import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class SubstrateTransactionMemoView extends StatelessWidget {
  const SubstrateTransactionMemoView(this.controller, {Key? key})
      : super(key: key);
  final SubstrateTransactionStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("setup_memo".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        Column(
          children: List.generate(controller.memos.length, (index) {
            return ContainerWithBorder(
              onRemoveIcon: const Icon(Icons.remove_circle),
              onRemove: () {
                controller.removeMemo(index);
              },
              child: Text(controller.memos[index], maxLines: 2),
            );
          }),
        ),
        ContainerWithBorder(
            onRemoveIcon: const Icon(Icons.add_box),
            onRemove: () {
              controller.onTapMemo(() async {
                final result = await context.openSliverBottomSheet<String>(
                  "transaction_memo".tr,
                  child: StringWriterView(
                    title: PageTitleSubtitle(
                        title: "setup_memo".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("memo_desc1".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr),
                          ],
                        )),
                    buttonText: "setup_memo".tr,
                    label: "memo".tr,
                  ),
                );
                return result;
              });
            },
            child: Text("tap_to_add_memo".tr,
                style: context.textTheme.labelLarge)),
      ],
    );
  }
}
