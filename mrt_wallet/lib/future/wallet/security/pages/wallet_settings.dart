import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_wallet_infos.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class UpdateWalletSettingView extends StatelessWidget {
  const UpdateWalletSettingView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _ExportSeedView(password: password);
        },
        title: "wallet_preferences".tr,
        subtitle: PageTitleSubtitle(
            title: "customize_wallet_settings".tr,
            body: Column(
              children: [
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _ExportSeedView extends StatefulWidget {
  const _ExportSeedView({required this.password});

  final String password;

  @override
  State<_ExportSeedView> createState() => _ExportSeedViewState();
}

class _ExportSeedViewState extends State<_ExportSeedView> with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  late final HDWallet hdWallet;
  late String name = hdWallet.name;
  late bool reqPassword = hdWallet.requiredPassword;
  late bool defaultWallet = true;
  late bool protectWallet = hdWallet.protectWallet;
  late WalletLockTime locktime = hdWallet.locktime;
  late List<String> walletIds;

  bool inited = false;
  void init() {
    if (!inited) {
      inited = true;
      final wallet = context.watch<WalletProvider>(StateConst.main);
      hdWallet = wallet.wallet.wallet;
      walletIds = wallet.wallet.wallets.map((e) => e.name).toList();
      walletIds.remove(hdWallet.name);
      defaultWallet = wallet.wallet.defaultWalletId == hdWallet.name;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  void setup(WalletUpdateInfosData walletInfos) async {
    name = walletInfos.name;
    locktime = walletInfos.lockTime;
    reqPassword = walletInfos.requirmentPassword;
    defaultWallet = walletInfos.asDefaultWallet;
    protectWallet = walletInfos.protectWallet;

    progressKey.progressText("updating".tr);
    final model = context.watch<WalletProvider>(StateConst.main).wallet;

    final result = await model.updateWalletInfos(
        password: widget.password, walletInfos: walletInfos);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("setting_update_successfully".tr,
          backToIdle: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Center(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: ConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                alignment: Alignment.center,
                child: UpdateWalletInfosWidget(
                  name: name,
                  locktime: locktime,
                  requrmentPassword: reqPassword,
                  exitsIds: walletIds,
                  asDefaultWallet: defaultWallet,
                  setupButtonTitle: "update_settings".tr,
                  onUpdate: (update) => setup(update),
                  protectWallet: protectWallet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
