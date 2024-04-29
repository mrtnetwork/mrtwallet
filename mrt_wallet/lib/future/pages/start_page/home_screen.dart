import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/about.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/setup_pages/setup.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
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
            key: Repository.scaffoldKey(context),
            resizeToAvoidBottomInset: true,
            bottomNavigationBar:
                !model.walletIsUnlock ? null : _BottomAppBar(model),
            body: UnfocusableChild(
              child: PageProgress(
                key: wallet.pageStatusHandler,
                backToIdle: AppGlobalConst.oneSecoundDuration,
                initialStatus: StreamWidgetStatus.progress,
                initialWidget:
                    ProgressWithTextView(text: "launch_the_wallet".tr),
                child: () => RefreshIndicator(
                  notificationPredicate: (notification) => model.walletIsUnlock,
                  onRefresh: model.updateBalance,
                  child: AnimatedSwitcher(
                    duration: AppGlobalConst.animationDuraion,
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
                                          AppGlobalConst.logo),
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
                                          context.to(PagePathConst.setup,
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
                                          context.to(PagePathConst.setup);
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
                                          context.to(PagePathConst.setup,
                                              argruments:
                                                  SetupWalletMode.backup);
                                        },
                                      ),
                                      WidgetConstant.height20,
                                      FilledButton(
                                          style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStatePropertyAll(
                                                      context
                                                          .colors.onBackground),
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      context
                                                          .colors.background)),
                                          onPressed: () {
                                            context.openSliverDialog(
                                                (ctx) =>
                                                    const AbountWalletView(),
                                                AppGlobalConst.name);
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
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
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
                        .openSliverBottomSheet<CryptoAccountAddress>(
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
                                        PagePathConst.setupAddressPage(
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
                            context.to(PagePathConst.importEVMNetwork);
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
                    context.to(PagePathConst.setting);
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
