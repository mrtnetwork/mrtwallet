import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class SetupWallet extends StatelessWidget {
  const SetupWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final setupMode = context.getNullArgruments<SetupWalletMode>() ??
        SetupWalletMode.generate;

    return MrtViewBuilder<SetupWalletController>(
      controller: () => SetupWalletController(setupMode),
      builder: (model) {
        return WillPopScope(
          onWillPop: model.backButton,
          child: ScaffolPageView(
            appBar: AppBar(title: Text("setup".tr)),
            child: PageProgress(
              key: model.progressKey,
              backToIdle: AppGlobalConst.oneSecoundDuration,
              child: () => UnfocusableChild(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                        child: ConstraintsBoxView(
                      padding: WidgetConstant.padding20,
                      child: AnimatedSwitcher(
                        duration: AppGlobalConst.animationDuraion,
                        child: _SetupWalletPages(
                          model.page,
                          model.mnemonic?.toList(),
                          key: ValueKey<SetupWalletPage>(model.page),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SetupWalletPages extends StatelessWidget {
  const _SetupWalletPages(this.page, this.mnemonic, {super.key});
  final List<String>? mnemonic;
  final SetupWalletPage page;
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case SetupWalletPage.password:
        return const SetupWalletPassword();
      case SetupWalletPage.confirm:
        return VerifyMnemonicView(mnemonic: mnemonic!);
      case SetupWalletPage.mnemonic:
        return const GenerateMnemonicView();
      case SetupWalletPage.extraOption:
        return const MnemonicExtraOptionView();
      case SetupWalletPage.enterMnemonic:
        return const EnterMnemonicView();
      case SetupWalletPage.backup:
        return const EnterMnemonicBackupView();
    }
  }
}
