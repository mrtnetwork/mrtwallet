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
                            ),
                            maxExtend: 0.7,
                            minExtent: 0.5,
                            initialExtend: 0.6)
                        .then((value) {
                      if (value == null) return;
                      transaction.setFee(value.$1, customFee: value.$2);
                    });
                  }
                : null,
            onRemoveIcon: transaction.gasInited
                ? const Icon(Icons.edit)
                : const Icon(Icons.circle),
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
                                    style: context.textTheme.labelLarge),
                              CoinPriceView(
                                  token: transaction.network.coinParam.token,
                                  balance: transaction.currentEIP1559Fee!.fee,
                                  style: context.textTheme.titleLarge)
                            ],
                          ),
                        ),
                      ],
                    ),
                false: (c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Text("retrieving_network_condition".tr)],
                    )
              },
            )),
      ],
    );
  }
}
