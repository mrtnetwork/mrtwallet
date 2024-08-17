import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class EthereumWeb3RequestAccountsView extends StatelessWidget {
  const EthereumWeb3RequestAccountsView(
      {required this.field, required this.controller, Key? key})
      : super(key: key);
  final EthereumRequestAccountForm field;
  final Web3EthereumGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ethereum_networks".tr,
                  style: context.textTheme.titleMedium),
              Text("evm_account_permission_desc".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                  label: "network".tr,
                  items: {
                    for (final i in field.chains)
                      i: Text(i.network.coinParam.token.name)
                  },
                  onChanged: field.onChangeChain,
                  value: field.chain),
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

                        return ContainerWithBorder(
                          onRemove: () {
                            field.addAccount(addr);
                          },
                          onRemoveWidget: IgnorePointer(
                              child: Checkbox(
                                  value: field.hasPermission(addr),
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
