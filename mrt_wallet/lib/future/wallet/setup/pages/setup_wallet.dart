import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'enter_backup_new.dart';
import 'enter_mnemonic.dart';
import 'extra_options.dart';
import 'generate_mnemonic.dart';
import 'setup_password.dart';
import 'verify_mnemonic.dart';
import 'wallet_setting.dart';

class SetupWallet extends StatelessWidget {
  const SetupWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final setupMode = context.getNullArgruments<SetupWalletMode>() ??
        SetupWalletMode.generate;
    final walletProvider = context.watch<WalletProvider>(StateConst.main);

    return MrtViewBuilder<SetupWalletController>(
      controller: () => SetupWalletController(setupMode, walletProvider),
      repositoryId: StateConst.setup,
      builder: (model) {
        return PopScope(
          canPop: model.page == SetupWalletPage.password,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              model.backButton();
            }
          },
          child: ScaffolPageView(
            appBar: AppBar(title: Text("setup".tr)),
            child: UnfocusableChild(
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
                          page: model.page,
                          mnemonic: model.mnemonic?.toList(),
                          onValidate: model.toExtra,
                          wallet: model.wallet,
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
  const _SetupWalletPages(
      {required this.page,
      this.mnemonic,
      required this.onValidate,
      this.wallet,
      super.key});
  final List<String>? mnemonic;
  final SetupWalletPage page;
  final OnValidateMnemonic onValidate;
  final HDWallet? wallet;

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
        return const EnterWalletBackupView();
      default:
        return CreateWalletSettingsView(wallet!);
    }
  }
}
