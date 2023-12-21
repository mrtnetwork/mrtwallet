import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/setup_transaction_fee.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/global/create_ripple_memo.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/transaction_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/global/memo.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleMemoAndFeeView<T extends RippleTransactionImpl>
    extends StatelessWidget {
  const RippleMemoAndFeeView({super.key, required this.controller});
  final T controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetConstant.height20,
        RippleMemosView(
          memos: controller.memos,
          onTapMemo: (memo) {
            controller.onSetupMemo(
                memo,
                (memo) => context.openSliverBottomSheet<XRPLMemo>(
                    "create_memo".tr,
                    child: CreateRippleMemoView(memo: memo)));
          },
          onCreateMemo: () {
            controller.onSetupMemo(
                null,
                (p0) => context.openSliverBottomSheet<XRPLMemo>(
                    "create_memo".tr,
                    child: const CreateRippleMemoView()));
          },
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: () {
              context
                  .openSliverBottomSheet<(String?, BigInt?)>(
                "transaction_fee".tr,
                child: SetupTransactionFee(
                  fees: controller.fees,
                  network: controller.network,
                  type: controller.feeType?.name,
                  max: controller.account.address.address.balance.value.balance,
                  customFee: controller.fee.balance,
                ),
              )
                  .then((value) {
                controller.setFee(value?.$1, customFee: value?.$2);
              });
            },
            onRemoveIcon: const Icon(Icons.edit),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.feeType?.name.camelCase ?? "custom_fee".tr,
                    style: context.textTheme.labelLarge),
                CoinPriceView(
                    token: controller.network.coinParam.token,
                    balance: controller.fee,
                    style: context.textTheme.titleLarge),
              ],
            )),
      ],
    );
  }
}
