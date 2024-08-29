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
              Text("active_chain".tr, style: context.textTheme.titleMedium),
              Text("web3_switch_chain_desc".tr,
                  style: context.textTheme.bodyMedium),
              WidgetConstant.height8,
              AppDropDownBottom(
                label: "network".tr,
                items: {
                  for (final i in field.chains)
                    i: Text(i.network.coinParam.token.name)
                },
                value: field.activeChain,
                onChanged: field.onChangeActiveChain,
              ),
              WidgetConstant.height20,
              Text("tron_networks".tr, style: context.textTheme.titleMedium),
              Text("chain_permission_desc".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                  label: "network".tr,
                  items: {
                    for (final i in field.chains)
                      i: Text(i.network.coinParam.token.name)
                  },
                  onChanged: field.onChangeChain,
                  value: field.chain),
              if (field.chainPermission.isNotEmpty) ...[
                WidgetConstant.height20,
                Text("default_address".tr,
                    style: context.textTheme.titleMedium),
                Text("default_address_desc".tr),
                WidgetConstant.height8,
                AppDropDownBottom(
                    isExpanded: true,
                    label: "default_address".tr,
                    items: {
                      for (final i in field.chainPermission)
                        i: Text(i.address.toAddress())
                    },
                    onChanged: field.onChangeDefaultPermission,
                    value: field.defaultChainAccount),
              ],
              WidgetConstant.height20,
              Text("accounts".tr, style: context.textTheme.titleMedium),
              Text("web3_accounts_permission_desc".tr),
              WidgetConstant.height8,
            ],
          ),
        ),
        APPSliverAnimatedSwitcher(enable: field.chain.haveAddress, widgets: {
          true: (c) => SliverMainAxisGroup(
                slivers: [
                  SliverList.builder(
                      addAutomaticKeepAlives: false,
                      itemBuilder: (c, index) {
                        final addr = field.chain.addresses[index];
                        final permission = field.accountPermission(addr);
                        return ContainerWithBorder(
                          onRemove: () {
                            field.addAccount(addr);
                          },
                          onRemoveWidget: IgnorePointer(
                              child: Checkbox(
                                  value: permission != null,
                                  onChanged: (e) {})),
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
          false: (c) => SliverToBoxAdapter(
              child: NoAccountFoundInChainWidget(field.chain))
        }),
      ],
    );
  }
}
