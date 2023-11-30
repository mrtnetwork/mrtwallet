import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/extention/context.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SwitchNetworkView extends StatelessWidget {
  const SwitchNetworkView({required this.selectedNetwork, super.key});
  final AppNetworkImpl selectedNetwork;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final len = AppBitcoinNetwork.values.length;
        final lastIndex = index + 1 == len;
        return Column(
          children: [
            InkWell(
              borderRadius: WidgetConstant.border8,
              onTap: selectedNetwork == AppBitcoinNetwork.values[index]
                  ? null
                  : () {
                      context.pop(AppBitcoinNetwork.values[index]);
                    },
              child: Padding(
                padding: WidgetConstant.padding5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAssetsImgaeView(
                          AppBitcoinNetwork.values[index].coinParam.logo,
                          radius: 20,
                        ),
                        WidgetConstant.width8,
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                AppBitcoinNetwork
                                    .values[index].coinParam.coinSymbol,
                                style: context.textTheme.labelLarge),
                            OneLineTextWidget(AppBitcoinNetwork
                                .values[index].coinParam.coinName),
                          ],
                        )),
                        WidgetConstant.width8,
                        if (selectedNetwork == AppBitcoinNetwork.values[index])
                          const Icon(Icons.check_circle)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!lastIndex) const Divider()
          ],
        );
      },
      itemCount: AppBitcoinNetwork.values.length,
    );
  }
}
