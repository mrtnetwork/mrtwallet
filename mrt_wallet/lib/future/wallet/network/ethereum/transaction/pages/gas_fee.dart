import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/pages/fee_select.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class EthereumGasFeeView extends StatelessWidget {
  const EthereumGasFeeView({super.key, required this.transaction});
  final ETHTransactionFeeImpl transaction;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: transaction.gasInited
                ? () {
                    context
                        .openSliverBottomSheet<
                                (
                                  EIP1559FeeSpeed speed,
                                  EthereumFee?
                                )>("transaction_fee".tr,
                            child: ETHEip1559GasViewSelectView(
                              transaction: transaction,
                            ))
                        .then((value) {
                      if (value == null) return;
                      transaction.setFee(value.$1, customFee: value.$2);
                    });
                  }
                : null,
            onRemoveIcon: AddOrEditIconWidget(transaction.gasInited),
            child: APPAnimatedSwitcher(
              enable: transaction.gasInited,
              widgets: {
                true: (c) => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (transaction.network.coinParam.supportEIP1559)
                                Text(transaction.feeSpeed.value.tr,
                                    style:
                                        context.onPrimaryTextTheme.labelLarge),
                              CoinPriceView(
                                token: transaction.network.coinParam.token,
                                balance: transaction.currentEIP1559Fee!.fee,
                                style: context.onPrimaryTextTheme.titleMedium,
                                symbolColor: context.onPrimaryContainer,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                false: (c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "retrieving_network_condition".tr,
                          style: context.onPrimaryTextTheme.bodyMedium,
                        )
                      ],
                    )
              },
            )),
      ],
    );
  }
}
