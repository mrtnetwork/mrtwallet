import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/others/models/status.dart';
import 'package:mrt_wallet/wallet/wallet.dart' show CryptoAddress, HDWallet;
import 'account_page.dart';
import 'appbar.dart';
import 'login_page.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'setup.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);

    return MrtViewBuilder<WalletProvider>(
      removable: false,
      controller: () => wallet,
      builder: (model) {
        return MaterialPageView(
          child: FullPageProgressWidget(
            key: wallet.pageStatusHandler,
            backToIdle: APPConst.oneSecoundDuration,
            initialStatus: StreamWidgetStatus.progress,
            initialWidget: ProgressWithTextView(text: "launch_the_wallet".tr),
            appBar: (c, s) => _CustomAppBar(
              isOpen: wallet.isOpen,
              hideAppbar: s.inProgress || !wallet.homePageStatus.isReady,
              child: _AccountAppBar(wallet),
            ),
            scaffoldKey: context.scaffoldKey,
            bottomNavigationBar: (c, s) {
              if (s.inProgress || !model.isOpen) return null;
              return _BottomAppBar(model);
            },
            child: (c) => UnfocusableChild(
              child: RefreshIndicator(
                notificationPredicate: (notification) => model.isOpen,
                onRefresh: model.updateBalance,
                child: APPAnimatedSwitcher(
                    enable: wallet.homePageStatus,
                    widgets: {
                      WalletStatus.setup: (c) => const WalletSetupPageWidget(),
                      WalletStatus.ready: (c) =>
                          APPAnimatedSwitcher(enable: wallet.isOpen, widgets: {
                            true: (c) => NetworkAccountPageView(wallet: model),
                            false: (c) => const WalletLoginPageView()
                          }),
                    }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar(this.model);
  final WalletProvider model;

  final FloatingActionButtonLocation fabLocation =
      FloatingActionButtonLocation.endDocked;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return BottomAppBar(
      color: context.colors.primary,
      child: IconTheme(
        data: IconThemeData(color: context.colors.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh_sharp),
                  tooltip: "switch_address".tr,
                  onPressed: () {
                    context
                        .openSliverBottomSheet<CryptoAddress>(
                          "switch_account".tr,
                          child: SwitchOrSelectAccountView(
                            account: wallet.chain.account,
                            showMultiSig: true,
                          ),
                          centerContent: false,
                          appbarActions: [
                            Padding(
                              padding: WidgetConstant.paddingHorizontal10,
                              child: IconButton(
                                  onPressed: () {
                                    context.to(PageRouter.setupGenericAddress,
                                        argruments: wallet.chain.account);
                                  },
                                  icon: const Icon(Icons.add_box),
                                  tooltip: "new_address".tr),
                            )
                          ],
                          minExtent: 0.5,
                          maxExtend: 0.9,
                          initialExtend: 0.7,
                        )
                        .then(wallet.switchAccount);
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: "lock_wallet".tr,
                  icon: const Icon(Icons.lock),
                  onPressed: () {
                    model.lock();
                  },
                ),
                SelectProviderIcon(key: UniqueKey()),
                IconButton(
                    tooltip: "switch_network".tr,
                    onPressed: () async {
                      context
                          .openDialogPage<int>(
                        "switch_network".tr,
                        fullWidget: SwitchNetworkView(
                          selectedNetwork: model.network,
                        ),
                      )
                          .then(
                        (value) {
                          if (value == null) return;
                          if (value.isNegative) {
                            context.to(PageRouter.importEthereumNetwork);
                          } else {
                            model.switchNetwork(value);
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.account_tree_sharp)),
                IconButton(
                  tooltip: 'settings'.tr,
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // wallet.eraseAll();
                    context.to(PageRouter.setting);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar(
      {required this.child, required this.isOpen, required this.hideAppbar});
  final Widget child;
  final bool isOpen;
  final bool hideAppbar;
  static const double onActiveSize = kToolbarHeight + 80;

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSize(
        isActive: !hideAppbar,
        onActive: (p0) => child,
        onDeactive: (p0) => WidgetConstant.sizedBox);
  }

  @override
  Size get preferredSize => hideAppbar
      ? Size.zero
      : Size.fromHeight(isOpen ? onActiveSize : kToolbarHeight);
}

class _AccountAppBar extends StatelessWidget {
  const _AccountAppBar(this.wallet);
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      // toolbarHeight: 0,
      title: Text(wallet.wallet.name),
      leading: IconButton(
          onPressed: () {
            context
                .openSliverDialog<HDWallet>(
                    (c) => SwitchWalletView(
                          wallets: wallet.wallets,
                          selectedWallet: wallet.wallet,
                        ),
                    "switch_wallets".tr,
                    content: (c) => [
                          IconButton(
                              onPressed: () {
                                context.offTo(PageRouter.createWallet);
                              },
                              icon: const Icon(Icons.add))
                        ])
                .then(wallet.switchWallet);
          },
          icon: const Icon(Icons.account_balance_wallet_rounded)),
      // foregroundColor: context.colors.onSurface,
      bottom: wallet.isOpen && wallet.chain.haveAddress
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: SizedBox(
                height: 80,
                child: AccountAppBarView(
                  account: wallet.chain.account.address,
                  onPressed: (p0) {
                    switch (p0) {
                      case 1:
                        context.to(PageRouter.showPublicKey,
                            argruments: wallet.chain.account.address);

                        break;
                      case 0:
                        context.to(PageRouter.exportPrivateKey,
                            argruments: wallet.chain.account.address);
                        break;
                      case 2:
                        context.to(PageRouter.removeAccount,
                            argruments: wallet.chain.account.address);
                      case 3:
                        context
                            .openSliverBottomSheet<String>(
                              "account_name".tr,
                              child: StringWriterView(
                                defaultValue:
                                    wallet.chain.account.address.accountName,
                                regExp: APPConst.accountNameRegExp,
                                title: PageTitleSubtitle(
                                    title: "setup_or_update_account_name".tr,
                                    body: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("setup_or_update_account_name".tr),
                                        WidgetConstant.height8,
                                        Text("remove_account_name_desc".tr),
                                      ],
                                    )),
                                buttonText: "setup_input".tr,
                                label: "account_name".tr,
                              ),
                            )
                            .then((value) => wallet.setupAccountName(
                                value, wallet.chain.account.address));

                      default:
                    }
                  },
                ),
              ),
            )
          : null,
    );
  }
}

class SwitchWalletView extends StatelessWidget {
  const SwitchWalletView(
      {required this.wallets, required this.selectedWallet, Key? key})
      : super(key: key);
  final List<HDWallet> wallets;
  final HDWallet selectedWallet;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        final bool selected = selectedWallet.name == wallet.name;
        return ContainerWithBorder(
          onRemove: () {
            context.pop(wallet);
          },
          onTapWhenOnRemove: selected ? false : true,
          onRemoveWidget: selected
              ? const Icon(Icons.check_circle)
              : WidgetConstant.sizedBox,
          child: Row(
            children: [
              wallet.requiredPassword
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.lock_open),
              WidgetConstant.width8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wallet.name, style: context.textTheme.labelLarge),
                    Text(wallet.created.toString(),
                        style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: wallets.length,
      shrinkWrap: true,
    );
  }
}
