import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class TronWeb3RequestAccountsView extends StatelessWidget {
  const TronWeb3RequestAccountsView(
      {required this.field, required this.controller, Key? key})
      : super(key: key);
  final TronRequestAccountForm field;
  final Web3TronGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("tron_networks".tr, style: context.textTheme.titleMedium),
              Text("chain_permission_desc".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                items: {
                  for (final i in field.chains)
                    i: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAPPImageView(i.network.token.assetLogo,
                            radius: 15),
                        WidgetConstant.width8,
                        Flexible(
                          child: OneLineTextWidget(
                            i.network.token.name,
                            style: context.textTheme.labelLarge,
                          ),
                        )
                      ],
                    )
                },
                onChanged: field.onChangeChain,
                value: field.chain,
                isExpanded: true,
              ),
              WidgetConstant.height20,
              Text("accounts".tr, style: context.textTheme.titleMedium),
              Text("web3_accounts_permission_desc".tr),
              WidgetConstant.height8,
            ],
          ),
        ),
        if (!field.chain.haveAddress)
          SliverToBoxAdapter(child: NoAccountFoundInChainWidget(field.chain))
        else
          APPSliverAnimatedSwitcher(enable: field.chain, widgets: {
            field.chain: (c) => SliverMainAxisGroup(
                  slivers: [
                    SliverList.builder(
                        addAutomaticKeepAlives: false,
                        itemBuilder: (c, index) {
                          final addr = field.chain.addresses[index];
                          final permission = field.accountPermission(addr);
                          return ContainerWithBorder(
                            onTapWhenOnRemove: false,
                            onRemove: () {
                              field.addAccount(addr);
                            },
                            onRemoveWidget: Column(
                              children: [
                                IconButton(
                                  onPressed: () => field.addAccount(addr),
                                  icon: IgnorePointer(
                                    child: Checkbox(
                                        value: permission != null,
                                        onChanged: (e) {}),
                                  ),
                                ),
                                APPAnimatedSize(
                                    isActive: permission != null,
                                    onActive: (context) => IconButton(
                                        tooltip: "default_address".tr,
                                        onPressed: () =>
                                            field.onChangeDefaultPermission(
                                                permission),
                                        icon: IgnorePointer(
                                          child: Radio<bool>(
                                              value: permission!.defaultAddress,
                                              groupValue: true,
                                              onChanged: (e) {}),
                                        )),
                                    onDeactive: (context) =>
                                        WidgetConstant.sizedBox)
                              ],
                            ),
                            child: AddressDetailsView(address: addr),
                          );
                        },
                        itemCount: field.chain.addresses.length),
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                              padding: WidgetConstant.paddingVertical40,
                              child: Text("update_permission".tr),
                              onPressed: () {
                                field.complete();
                              }),
                        ],
                      ),
                    )
                  ],
                ),
          }),
      ],
    );
  }
}
