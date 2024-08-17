import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/security/security.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class BackupWalletView extends StatelessWidget {
  const BackupWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _BackupWallet(password: password);
        },
        title: "backup".tr,
        subtitle: PageTitleSubtitle(
            title: "backup_wallet".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("backup_wallet_desc".tr),
                WidgetConstant.height8,
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _BackupWallet extends StatefulWidget {
  const _BackupWallet({required this.password});
  final String password;

  @override
  State<_BackupWallet> createState() => _BackupWalletState();
}

class _BackupWalletState extends State<_BackupWallet> with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => ConstraintsBoxView(
        padding: WidgetConstant.padding20,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitleSubtitle(
                    title: "backup_wallet".tr,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("backup_wallet_desc".tr),
                        WidgetConstant.height8,
                        Text("backup_wallet_desc1".tr)
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: WidgetConstant.paddingVertical20,
                      child: FilledButton.icon(
                          label: Text("create_backup".tr),
                          onPressed: () {
                            context.openSliverDialog(
                                (ctx) => GenerateBackupView(
                                    data: "",
                                    password: widget.password,
                                    type: MrtBackupTypes.wallet),
                                "backup_wallet".tr);
                          },
                          icon: const Icon(Icons.backup)),
                    )
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
