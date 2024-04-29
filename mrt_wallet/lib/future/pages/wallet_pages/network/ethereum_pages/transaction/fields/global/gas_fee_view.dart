import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/controller/impl/fee_impl.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ethereum_pages/transaction/fields/global/eip_gas_fee_select_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/custom.dart';

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
            child: AnimatedSwitcher(
              duration: AppGlobalConst.animationDuraion,
              child: Row(
                key: UniqueKey(),
                // key: ValueKey<String>(
                //     "${transaction.gasInited}/${transaction.updatingGas}"),
                children: [
                  Expanded(
                    child: transaction.gasInited
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (transaction.network.coinParam.supportEIP1559)
                                Text(transaction.feeSpeed.value.tr,
                                    style: context.textTheme.labelLarge),
                              CoinPriceView(
                                  token: transaction.network.coinParam.token,
                                  balance: transaction.currentEIP1559Fee!.fee,
                                  style: context.textTheme.titleLarge)
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Text("retrieving_network_condition".tr)],
                          ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
