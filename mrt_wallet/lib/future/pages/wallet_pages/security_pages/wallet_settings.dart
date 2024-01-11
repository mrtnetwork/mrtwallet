import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class UpdateWalletSettingView extends StatelessWidget {
  const UpdateWalletSettingView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (p0, p1) {
          return _ExportSeedView(password: p1);
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
  late final WalletSetting setting;
  late final Map<WalletLockTime, Widget> lockTime = {
    for (final i in WalletLockTime.values) i: Text(i.viewName.tr)
  };
  late WalletLockTime selected;
  bool inited = false;

  void onChanged(WalletLockTime? v) {
    selected = v ?? selected;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    if (!inited) {
      inited = true;
      setting = context.watch<WalletProvider>(StateIdsConst.main).setting;
      selected = setting.lockTime;
    }
    super.didChangeDependencies();
  }

  void onUpdate() async {
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    progressKey.progressText("updating".tr);
    final result = await model.updateWlletSetting(
        widget.password, setting.copyWith(lockTime: selected));
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
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => ConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: AppGlobalConst.animationDuraion,
          child: SingleChildScrollView(
            child: Column(
              children: [
                PageTitleSubtitle(
                    title: "customize_wallet_settings".tr,
                    body: Text("update_settings_desc".tr)),
                AppDropDownBottom(
                  items: lockTime,
                  label: "automatic_loc".tr,
                  value: selected,
                  onChanged: onChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical20,
                      onPressed: onUpdate,
                      child: Text("update_settings".tr),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
