import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/theme/theme.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/setting/color_selector.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

import 'about.dart';

class WalletSetupPageWidget extends StatelessWidget {
  const WalletSetupPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
        controller: () => context.watch<WalletProvider>(StateConst.main),
        removable: false,
        repositoryId: StateConst.main,
        builder: (wallet) {
          return Center(
            child: CustomScrollView(
              shrinkWrap: false,
              slivers: [
                SliverAppBar(
                  title: Text("setup".tr),
                  pinned: true,
                  centerTitle: false,
                  actions: [
                    BrightnessToggleIcon(
                        onToggleBrightness: () => wallet.toggleBrightness(),
                        brightness: ThemeController.appTheme.brightness),
                    ColorSelectorIconView(
                      (p0) {
                        if (p0 == null) return;
                        return wallet.changeColor(p0);
                      },
                    ),
                    WidgetConstant.width8,
                  ],
                ),
                SliverFillRemaining(
                  child: Center(
                    child: CustomScrollView(
                      shrinkWrap: true,
                      slivers: [
                        SliverConstraintsBoxView(
                            sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAssetsImgaeView(APPConst.logo),
                              WidgetConstant.height8,
                              AppListTile(
                                title: Text("use_mnemonic".tr),
                                subtitle: Text("e_mnemonic".tr),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () async {
                                  context.to(PageRouter.setup,
                                      argruments: SetupWalletMode.exist);
                                },
                              ),
                              WidgetConstant.height8,
                              AppListTile(
                                title: Text("generate_mnemonic".tr),
                                subtitle: Text("g_mnemonic".tr),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  context.to(PageRouter.setup);
                                },
                              ),
                              WidgetConstant.height8,
                              AppListTile(
                                title: Text("restore_backup".tr),
                                subtitle: Text("restore_backuo_desc".tr),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  context.to(PageRouter.setup,
                                      argruments: SetupWalletMode.backup);
                                },
                              ),
                              Padding(
                                padding: WidgetConstant.paddingVertical40,
                                child: FilledButton(
                                    style: ButtonStyle(
                                        foregroundColor: WidgetStatePropertyAll(
                                            context.colors.onSurface),
                                        backgroundColor: WidgetStatePropertyAll(
                                            context.colors.surface)),
                                    onPressed: () async {
                                      context.openSliverDialog(
                                          (c) => const AbountWalletView(),
                                          APPConst.name);
                                    },
                                    child: Text("about_mrt_wallet".tr)),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                WidgetConstant.sliverPaddingVertial20,
              ],
            ),
          );
        });
  }
}
