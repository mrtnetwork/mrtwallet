import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';

typedef HASPERMISSION<ACCOUNT, CHAINACCOUNT> = CHAINACCOUNT? Function(ACCOUNT);
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
      required this.onUpdateState,
      required this.hasPermission,
      required this.addAccount,
      required this.onChangeChain,
      required this.onChangeDefaultAccount,
      Key? key})
      : super(key: key);
  final CHAIN chain;
  final List<CHAIN> chains;
  final DynamicVoid onUpdateState;
  final HASPERMISSION<ADDRESS, CHAINACCOUNT> hasPermission;
  final OnChangeCurrentChain<CHAIN> onChangeChain;
  final ADDPERMISSIONACCOUNT<ADDRESS> addAccount;
  final ONCHANGEDEFAULTACCOUNT<CHAINACCOUNT> onChangeDefaultAccount;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverAppBar(
        leading: WidgetConstant.sizedBox,
        surfaceTintColor: context.colors.transparent,
        centerTitle: false,
        backgroundColor: context.colors.surface,
        leadingWidth: 0,
        actions: [
          TappedTooltipView(
            tooltipWidget: ToolTipView(
              message: "switch_permission_chain_desc".tr,
              child: const Icon(Icons.help),
            ),
          ),
          WidgetConstant.width8,
        ],
        title: AppDropDownBottom(
            focusColor: context.colors.surface,
            fillColor: context.colors.surface,
            label: null,
            isExpanded: true,
            items: {
              for (final i in chains)
                i: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAPPImageView(i.network.token.assetLogo, radius: 15),
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
            onChanged: onChangeChain,
            value: chain),
        pinned: true,
      ),
      SliverPadding(
        padding: WidgetConstant.paddingHorizontal10,
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height8,
              if (!chain.haveAddress)
                NoAccountFoundInChainWidget(chain, onClosePage: onUpdateState),
              APPAnimatedSwitcher(enable: chain, widgets: {
                chain: (c) => Column(
                      children: [
                        ListView.builder(
                            addAutomaticKeepAlives: false,
                            shrinkWrap: true,
                            physics: WidgetConstant.noScrollPhysics,
                            itemBuilder: (c, index) {
                              final addr = chain.addresses[index];
                              final permission = hasPermission(addr as ADDRESS);
                              return ContainerWithBorder(
                                onTapWhenOnRemove: false,
                                onRemove: () {
                                  addAccount(addr);
                                },
                                onRemoveWidget: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () => addAccount(addr),
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
                                                onChangeDefaultAccount(
                                                    permission),
                                            icon: IgnorePointer(
                                              child: Radio<bool>(
                                                  toggleable: true,
                                                  value: permission!
                                                      .defaultAddress,
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
                            itemCount: chain.addresses.length),
                        WidgetConstant.height40,
                      ],
                    ),
              }),
            ],
          ),
        ),
      )
    ]);
  }
}
