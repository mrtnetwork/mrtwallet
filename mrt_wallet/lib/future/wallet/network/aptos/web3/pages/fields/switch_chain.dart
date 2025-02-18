import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class AptosWeb3SwitchChainView extends StatelessWidget {
  const AptosWeb3SwitchChainView({required this.request, super.key});
  final Web3AptosSwitchAptosChain request;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "switch_chain"
                  .tr
                  .replaceOne(request.newChain.network.networkName),
              body: Text("switch_chain_desc".tr)),
          Text("current_chain".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Row(
              children: [
                CircleTokenImageView(request.request.chain.network.token,
                    radius: APPConst.circleRadius25),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.request.chain.network.networkName,
                          style: context.onPrimaryTextTheme.bodyMedium),
                      Text(
                          request.request.chain.network.coinParam.aptosChainType
                              .chainId.toRadix16,
                          style: context.onPrimaryTextTheme.bodySmall)
                    ],
                  ),
                ),
              ],
            ),
          ),
          WidgetConstant.height20,
          Text("requested_chain".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Row(
              children: [
                CircleTokenImageView(request.newChain.network.token,
                    radius: APPConst.circleRadius25),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.newChain.network.networkName,
                          style: context.onPrimaryTextTheme.bodyMedium),
                      Text(
                          request.newChain.network.coinParam.aptosChainType
                              .chainId.toRadix16,
                          style: context.onPrimaryTextTheme.bodySmall)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  child: Text("agree".tr),
                  onPressed: () {
                    request.confirmRequest();
                  })
            ],
          )
        ],
      ),
    );
  }
}
