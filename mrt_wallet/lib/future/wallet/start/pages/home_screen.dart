import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/start/pages/about.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/setup/setup.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart' show CryptoAddress;
import 'account_page.dart';
import 'login_page.dart';
import 'package:mrt_wallet/future/router/page_router.dart';

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
          child: Scaffold(
            appBar: model.walletIsUnlock
                ? null
                : AppBar(
                    title: Text(
                        model.walletIsLock ? "wallet_login".tr : "setup".tr),
                  ),
            key: context.scaffoldKey,
            resizeToAvoidBottomInset: true,
            bottomNavigationBar:
                !model.walletIsUnlock ? null : _BottomAppBar(model),
            body: UnfocusableChild(
              child: PageProgress(
                key: wallet.pageStatusHandler,
                backToIdle: APPConst.oneSecoundDuration,
                initialStatus: StreamWidgetStatus.progress,
                initialWidget:
                    ProgressWithTextView(text: "launch_the_wallet".tr),
                child: () => RefreshIndicator(
                  notificationPredicate: (notification) => model.walletIsUnlock,
                  onRefresh: model.updateBalance,
                  child: AnimatedSwitcher(
                    duration: APPConst.animationDuraion,
                    child: model.walletIsLock
                        ? const WalletLoginPageView()
                        : model.walletIsUnlock
                            ? NetworkAccountPageView(wallet: model)
                            : ConstraintsBoxView(
                                padding: WidgetConstant.padding20,
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const CircleAssetsImgaeView(
                                          APPConst.logo),
                                      WidgetConstant.height8,
                                      Text(
                                        "wellcome".tr,
                                        style: context.textTheme.titleLarge,
                                      ),
                                      WidgetConstant.height20,
                                      AppListTile(
                                        title: Text("use_mnemonic".tr),
                                        subtitle: Text("e_mnemonic".tr),
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                        onTap: () async {
                                          context.to(PageRouter.setup,
                                              argruments:
                                                  SetupWalletMode.exist);
                                        },
                                      ),
                                      WidgetConstant.height8,
                                      AppListTile(
                                        title: Text("generate_mnemonic".tr),
                                        subtitle: Text("g_mnemonic".tr),
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                        onTap: () {
                                          context.to(PageRouter.setup);
                                        },
                                      ),
                                      WidgetConstant.height8,
                                      AppListTile(
                                        title: Text("restore_backup".tr),
                                        subtitle:
                                            Text("restore_backuo_desc".tr),
                                        trailing:
                                            const Icon(Icons.arrow_forward),
                                        onTap: () {
                                          context.to(PageRouter.setup,
                                              argruments:
                                                  SetupWalletMode.backup);
                                        },
                                      ),
                                      WidgetConstant.height20,
                                      FilledButton(
                                          style: ButtonStyle(
                                              foregroundColor:
                                                  WidgetStatePropertyAll(
                                                      context.colors.onSurface),
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      context.colors.surface)),
                                          onPressed: () {
                                            context.openSliverDialog(
                                                (ctx) =>
                                                    const AbountWalletView(),
                                                APPConst.name);
                                          },
                                          child: Text("about_mrt_wallet".tr))
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ),
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
                                    context.to(
                                        PageRouter.setupAddressPage(
                                            wallet.network),
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