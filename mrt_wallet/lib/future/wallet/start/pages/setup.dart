import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'about.dart';

class WalletSetupPageView extends StatelessWidget {
  const WalletSetupPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: AppBar(title: Text("setup".tr)),
      child: const CustomScrollView(
        shrinkWrap: true,
        slivers: [SliverToBoxAdapter(child: WalletSetupPageWidget())],
      ),
    );
  }
}

class WalletSetupPageWidget extends StatelessWidget {
  const WalletSetupPageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: ConstraintsBoxView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAssetsImgaeView(APPConst.logo),
                  WidgetConstant.height8,
                  Text(
                    "wellcome".tr,
                    style: context.textTheme.titleLarge,
                  ),
                  WidgetConstant.height20,
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
                            backgroundColor:
                                WidgetStatePropertyAll(context.colors.surface)),
                        onPressed: () {
                          context.openSliverDialog(
                              (ctx) => const AbountWalletView(), APPConst.name);
                        },
                        child: Text("about_mrt_wallet".tr)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
