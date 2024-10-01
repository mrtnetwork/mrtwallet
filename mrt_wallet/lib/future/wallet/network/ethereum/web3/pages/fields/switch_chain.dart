import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class EthereumWeb3SwitchEthereumChainView extends StatelessWidget {
  const EthereumWeb3SwitchEthereumChainView({required this.request, Key? key})
      : super(key: key);
  final Web3EthereumSwitchEthereumChain request;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "switch_ethereum_chain".tr,
              body: Text("switch_ethereum_chain_desc".tr)),
          Text("current_chain".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            child: Row(
              children: [
                CircleTokenImageView(
                  request.request.chain.network.token,
                  radius: 40,
                ),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.request.chain.network.networkName,
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context),
                      ),
                      Text(
                        request.request.chain.chainId.toRadix16,
                        style: context.colors.onPrimaryContainer
                            .bodySmall(context),
                      )
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
                CircleTokenImageView(
                  request.newChain.network.token,
                  radius: 40,
                ),
                WidgetConstant.width8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.newChain.network.networkName,
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context),
                      ),
                      Text(
                        request.newChain.chainId.toRadix16,
                        style: context.colors.onPrimaryContainer
                            .bodySmall(context),
                      )
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
