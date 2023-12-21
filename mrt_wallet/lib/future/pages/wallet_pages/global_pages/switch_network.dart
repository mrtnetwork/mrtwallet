import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SwitchNetworkView extends StatefulWidget {
  const SwitchNetworkView({required this.selectedNetwork, super.key});
  final AppNetworkImpl selectedNetwork;

  @override
  State<SwitchNetworkView> createState() => _SwitchNetworkViewState();
}

class _SwitchNetworkViewState extends State<SwitchNetworkView> {
  double? height;
  void onChangeSize(Size size) {
    if (size.height != height) {
      height = size.height;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstraintsBoxView(
        alignment: Alignment.center,
        maxWidth: AppGlobalConst.dialogWidth,
        padding: WidgetConstant.padding20,
        child: ClipRRect(
          borderRadius: WidgetConstant.border8,
          child: Material(
            color: context.colors.background,
            child: DefaultTabController(
              length: 2,
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverAppBar(
                    title: Text("switch_network".tr),
                    leading: const SizedBox(),
                    leadingWidth: 0,
                    bottom: TabBar(tabs: [
                      Tab(text: "bitcoin_and_forked".tr),
                      Tab(text: "ripple".tr)
                    ]),
                    pinned: true,
                    actions: const [
                      CloseButton(),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                      padding: WidgetConstant.padding20,
                      maxHeight: 400,
                      child: TabBarView(children: [
                        _BitcoinAndForked(widget.selectedNetwork),
                        _RippleNetworks(widget.selectedNetwork)
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BitcoinAndForked extends StatelessWidget {
  const _BitcoinAndForked(this.selected);
  final AppNetworkImpl selected;
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
              onTap: selected == AppBitcoinNetwork.values[index]
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
                                    .values[index].coinParam.token.symbol,
                                style: context.textTheme.labelLarge),
                            OneLineTextWidget(AppBitcoinNetwork
                                .values[index].coinParam.token.name),
                          ],
                        )),
                        WidgetConstant.width8,
                        if (selected == AppBitcoinNetwork.values[index])
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

class _RippleNetworks extends StatelessWidget {
  const _RippleNetworks(this.selected);
  final AppNetworkImpl selected;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final len = AppXRPNetwork.values.length;
        final lastIndex = index + 1 == len;
        return Column(
          children: [
            InkWell(
              borderRadius: WidgetConstant.border8,
              onTap: selected == AppXRPNetwork.values[index]
                  ? null
                  : () {
                      context.pop(AppXRPNetwork.values[index]);
                    },
              child: Padding(
                padding: WidgetConstant.padding5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAssetsImgaeView(
                          AppXRPNetwork.values[index].coinParam.logo,
                          radius: 20,
                        ),
                        WidgetConstant.width8,
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                AppXRPNetwork
                                    .values[index].coinParam.token.symbol,
                                style: context.textTheme.labelLarge),
                            OneLineTextWidget(AppXRPNetwork
                                .values[index].coinParam.token.name),
                          ],
                        )),
                        WidgetConstant.width8,
                        if (selected == AppXRPNetwork.values[index])
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
      itemCount: AppXRPNetwork.values.length,
    );
  }
}
