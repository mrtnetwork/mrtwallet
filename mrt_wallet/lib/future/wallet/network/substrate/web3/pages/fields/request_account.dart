import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/web3/forms/requst_account.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/start/pages/account_not_adress.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class SubstrateWeb3RequestAccountsView extends StatelessWidget {
  const SubstrateWeb3RequestAccountsView(
      {required this.field, required this.controller, super.key});
  final SubstrateRequestAccountForm field;
  final Web3SubstrateGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("substrate_networks".tr,
                  style: context.textTheme.titleMedium),
              Text("chain_permission_desc".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                  items: {
                    for (final i in field.chains)
                      i: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAPPImageView(i.network.token.assetLogo,
                              radius: APPConst.circleRadius12),
                          WidgetConstant.width8,
                          Flexible(
                            child: OneLineTextWidget(i.network.token.name,
                                style: context.textTheme.labelLarge),
                          )
                        ],
                      )
                  },
                  isExpanded: true,
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
                        final permission = field.accountPermission(addr);
                        return ContainerWithBorder(
                          enableTap: false,
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
                          child: AddressDetailsView(
                            address: addr,
                            color: context.onPrimaryContainer,
                          ),
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
