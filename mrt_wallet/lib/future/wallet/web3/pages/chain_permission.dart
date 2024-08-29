import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';

typedef HASPERMISSION<ACCOUNT, NETWORKADDRESS>
    = Web3ChainAccount<NETWORKADDRESS>? Function(ACCOUNT);
typedef OnChangeCurrentChain<CHAIN> = void Function(CHAIN?);
typedef ADDPERMISSIONACCOUNT<ACCOUNT> = void Function(ACCOUNT);
typedef ONCHANGEDEFAULTACCOUNT<CHAINACCOUNT> = void Function(CHAINACCOUNT?);

class UpdateChainPermissionWidget<
        NETWORKADDRESS,
        CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
        ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
        CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>>
    extends StatelessWidget {
  const UpdateChainPermissionWidget(
      {required this.chain,
      required this.chains,
      required this.complete,
      required this.hasPermission,
      required this.onChangeCurrentChain,
      required this.addAccount,
      required this.onChangeChain,
      required this.onChangeDefaultAccount,
      required this.permissions,
      required this.defaultChainAddress,
      required this.activeChain,
      Key? key})
      : super(key: key);
  final CHAIN chain;
  final List<CHAIN> chains;
  final DynamicVoid complete;
  final HASPERMISSION<ADDRESS, NETWORKADDRESS> hasPermission;
  final OnChangeCurrentChain<CHAIN> onChangeCurrentChain;
  final OnChangeCurrentChain<CHAIN> onChangeChain;
  final ADDPERMISSIONACCOUNT<ADDRESS> addAccount;
  final ONCHANGEDEFAULTACCOUNT<CHAINACCOUNT> onChangeDefaultAccount;
  final List<CHAINACCOUNT> permissions;
  final CHAINACCOUNT? defaultChainAddress;
  final CHAIN activeChain;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("active_chain".tr, style: context.textTheme.titleMedium),
          Text("web3_switch_chain_desc".tr,
              style: context.textTheme.bodyMedium),
          WidgetConstant.height8,
          AppDropDownBottom<CHAIN>(
              label: "network".tr,
              items: {
                for (final i in chains) i: Text(i.network.coinParam.token.name)
              },
              onChanged: onChangeCurrentChain,
              value: activeChain),
          WidgetConstant.height20,
          Text("network".tr, style: context.textTheme.titleMedium),
          Text("chain_permission_desc".tr),
          WidgetConstant.height8,
          AppDropDownBottom(
              label: "network".tr,
              items: {
                for (final i in chains) i: Text(i.network.coinParam.token.name)
              },
              onChanged: onChangeChain,
              value: chain),
          APPAnimatedSize(
            isActive: permissions.isNotEmpty,
            onActive: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text("default_address".tr,
                    style: context.textTheme.titleMedium),
                Text("default_address_desc".tr),
                WidgetConstant.height8,
                AppDropDownBottom(
                    isExpanded: true,
                    label: "default_address".tr,
                    items: {for (final i in permissions) i: Text(i.addressStr)},
                    onChanged: onChangeDefaultAccount,
                    value: defaultChainAddress)
              ],
            ),
            onDeactive: (context) {
              return WidgetConstant.sizedBox;
            },
          ),
          WidgetConstant.height20,
          Text("accounts".tr, style: context.textTheme.titleMedium),
          Text("web3_accounts_permission_desc".tr),
          WidgetConstant.height8,
          APPAnimatedSwitcher(enable: chain.haveAddress, widgets: {
            true: (c) => Column(
                  children: [
                    ListView.builder(
                        addAutomaticKeepAlives: false,
                        shrinkWrap: true,
                        physics: WidgetConstant.noScrollPhysics,
                        itemBuilder: (c, index) {
                          final addr = chain.addresses[index];
                          final permission = hasPermission(addr as ADDRESS);

                          return ContainerWithBorder(
                            onRemove: () {
                              addAccount(addr);
                            },
                            onRemoveWidget: IgnorePointer(
                                child: Checkbox(
                                    value: permission != null,
                                    onChanged: (e) {})),
                            child: AddressDetailsView(address: addr),
                          );
                        },
                        itemCount: chain.addresses.length),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical40,
                            child: Text("update_permission".tr),
                            onPressed: () {
                              complete();
                            }),
                      ],
                    )
                  ],
                ),
            false: (c) => NoAccountFoundInChainWidget(chain)
          }),
        ],
      ),
    );
  }
}
