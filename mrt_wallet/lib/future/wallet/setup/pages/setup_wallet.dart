import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/setup/setup.dart';
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
        return PopScope(
          canPop: model.page == SetupWalletPage.password,
          onPopInvoked: (didPop) async {
            if (!didPop) {
              model.backButton();
            }
          },
          child: ScaffolPageView(
            appBar: AppBar(title: Text("setup".tr)),
            child: PageProgress(
              key: model.progressKey,
              backToIdle: APPConst.oneSecoundDuration,
              child: () => UnfocusableChild(
                child: Center(
                  child: CustomScrollView(
                    shrinkWrap: true,
                    slivers: [
                      SliverToBoxAdapter(
                          child: ConstraintsBoxView(
                        padding: WidgetConstant.padding20,
                        child: AnimatedSwitcher(
                          duration: APPConst.animationDuraion,
                          child: _SetupWalletPages(
                            model.page,
                            model.mnemonic?.toList(),
                            model.toExtra,
                            key: ValueKey<SetupWalletPage>(model.page),
                          ),
                        ),
                      )),
                    ],
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

class _SetupWalletPages extends StatelessWidget {
  const _SetupWalletPages(this.page, this.mnemonic, this.onValidate,
      {super.key});
  final List<String>? mnemonic;
  final SetupWalletPage page;
  final OnValidateMnemonic onValidate;
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case SetupWalletPage.password:
        return const SetupWalletPassword();
      case SetupWalletPage.confirm:
        return VerifyMnemonicView(mnemonic: mnemonic!, onValidate: onValidate);
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
