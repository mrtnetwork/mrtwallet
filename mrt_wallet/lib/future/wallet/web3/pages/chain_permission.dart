import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';
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
    extends StatefulWidget {
  const UpdateChainPermissionWidget(
      {required this.chain,
      required this.chains,
      required this.onUpdateState,
      required this.hasPermission,
      required this.addAccount,
      required this.onChangeChain,
      required this.onChangeDefaultAccount,
      required this.activities,
      super.key});
  final CHAIN chain;
  final List<CHAIN> chains;
  final DynamicVoid onUpdateState;
  final HASPERMISSION<ADDRESS, CHAINACCOUNT> hasPermission;
  final OnChangeCurrentChain<CHAIN> onChangeChain;
  final ADDPERMISSIONACCOUNT<ADDRESS> addAccount;
  final ONCHANGEDEFAULTACCOUNT<CHAINACCOUNT> onChangeDefaultAccount;
  final List<Web3ActivityViewItem> activities;

  @override
  State<UpdateChainPermissionWidget> createState() =>
      _UpdateChainPermissionWidgetState<NETWORKADDRESS, CHAIN, ADDRESS,
          CHAINACCOUNT>();
}

enum _Web3PermissionViewPage {
  accounts,
  histories;
}

class _UpdateChainPermissionWidgetState<
        NETWORKADDRESS,
        CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
        ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
        CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>>
    extends State<
        UpdateChainPermissionWidget<NETWORKADDRESS, CHAIN, ADDRESS,
            CHAINACCOUNT>> with AutomaticKeepAliveClientMixin {
  _Web3PermissionViewPage page = _Web3PermissionViewPage.accounts;

  void onChangeTab(int tab) {
    if (tab == 0) {
      page = _Web3PermissionViewPage.accounts;
    } else {
      page = _Web3PermissionViewPage.histories;
    }
    setState(() {});
  }

  APPCHAIN? chain;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.chain != chain) {
      page = _Web3PermissionViewPage.accounts;
      MethodUtils.after(
          () async => DefaultTabController.of(context).animateTo(0));
    }
  }

  @override
  void didUpdateWidget(
      covariant UpdateChainPermissionWidget<NETWORKADDRESS, CHAIN, ADDRESS,
              CHAINACCOUNT>
          oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SliverMainAxisGroup(slivers: [
      SliverAppBar(
          leading: WidgetConstant.sizedBox,
          surfaceTintColor: context.colors.transparent,
          centerTitle: false,
          backgroundColor: context.colors.surface,
          leadingWidth: 0,
          actions: [
            // TappedTooltipView(
            //   tooltipWidget: ToolTipView(
            //       message: "switch_permission_chain_desc".tr,
            //       child: const Icon(Icons.help)),
            // ),
            // WidgetConstant.width8
          ],
          title: AppDropDownBottom(
              focusColor: context.colors.surface,
              fillColor: context.colors.surface,
              label: null,
              isExpanded: true,
              items: {
                for (final i in widget.chains)
                  i: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAPPImageView(i.network.token.assetLogo, radius: 15),
                      WidgetConstant.width8,
                      Flexible(
                        child: OneLineTextWidget(i.network.token.name,
                            style: context.textTheme.labelLarge),
                      )
                    ],
                  )
              },
              onChanged: widget.onChangeChain,
              value: widget.chain),
          pinned: true,
          bottom: TabBar(onTap: onChangeTab, tabs: [
            Tab(text: "accounts".tr),
            Tab(text: "history".tr),
          ])),
      APPSliverAnimatedSwitcher(enable: page, widgets: {
        _Web3PermissionViewPage.accounts: (context) {
          return SliverPadding(
            padding: WidgetConstant.paddingHorizontal10,
            sliver: APPSliverAnimatedSwitcher(
                enable: widget.chain.haveAddress,
                widgets: {
                  true: (context) => SliverList.builder(
                      addAutomaticKeepAlives: false,
                      itemBuilder: (c, index) {
                        final addr = widget.chain.addresses[index];
                        final permission =
                            widget.hasPermission(addr as ADDRESS);
                        return ContainerWithBorder(
                          enableTap: false,
                          onRemove: () {
                            widget.addAccount(addr);
                          },
                          onRemoveWidget: Column(
                            children: [
                              IconButton(
                                onPressed: () => widget.addAccount(addr),
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
                                      onPressed: () => widget
                                          .onChangeDefaultAccount(permission),
                                      icon: IgnorePointer(
                                        child: Radio<bool>(
                                            toggleable: true,
                                            value: permission!.defaultAddress,
                                            groupValue: true,
                                            onChanged: (e) {}),
                                      )),
                                  onDeactive: (context) =>
                                      WidgetConstant.sizedBox)
                            ],
                          ),
                          child: AddressDetailsView(
                              address: addr, color: context.onPrimaryContainer),
                        );
                      },
                      itemCount: widget.chain.addresses.length),
                  false: (context) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: NoAccountFoundInChainWidget(widget.chain,
                          onClosePage: widget.onUpdateState))
                }),
          );
        },
        _Web3PermissionViewPage.histories: (context) {
          return _Web3ActivitiesView(widget.activities);
        }
      })
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class _Web3ActivitiesView extends StatelessWidget {
  const _Web3ActivitiesView(this.activities);
  final List<Web3ActivityViewItem> activities;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      ConditionalWidget(
          onActive: (context) {
            return SliverToBoxAdapter();
          },
          onDeactive: (context) => SliverToBoxAdapter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(padding: WidgetConstant.paddingVertical40),
                      Icon(Icons.hourglass_empty, size: APPConst.double40),
                      WidgetConstant.height8,
                      Text("no_web3_activities".tr)
                    ]),
              ),
          enable: activities.isNotEmpty),
      SliverList.separated(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ContainerWithBorder(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.activity.method.camelCase),
              Text(activity.activity.date.toDateAndTime(),
                  style: context.onPrimaryTextTheme.bodySmall),
              if (activity.address != null)
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  child: CopyableTextWidget(
                      text: activity.address!.view,
                      color: context.primaryContainer,
                      widget: ReceiptAddressDetailsView(
                          address: activity.address!,
                          color: context.primaryContainer)),
                ),
              if (activity.url != null)
                ContainerWithBorder(
                  backgroundColor: context.onPrimaryContainer,
                  onRemove: () {},
                  onRemoveIcon: LaunchBrowserIcon(
                      url: activity.url, color: context.primaryContainer),
                  child: OneLineTextWidget(
                      activity.activity.path ?? activity.url!,
                      style: context.primaryTextTheme.bodyMedium),
                )
            ]),
          );
        },
        separatorBuilder: (context, index) => WidgetConstant.divider,
      ),
    ]);
  }
}
