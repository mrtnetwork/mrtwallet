import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/backup/backup.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum _Pages { restore, content }

class RestoreBackupView extends StatefulWidget {
  const RestoreBackupView({Key? key, this.accepted}) : super(key: key);
  final MrtBackupTypes? accepted;

  @override
  State<RestoreBackupView> createState() => _RestoreBackupViewState();
}

class _RestoreBackupViewState extends State<RestoreBackupView> with SafeState {
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_RestoreBackupViewState");
  final GlobalKey<FormState> form =
      GlobalKey(debugLabel: "_RestoreBackupViewState_2");
  bool showContet = false;
  String backup = "";
  String password = "";

  _Pages page = _Pages.restore;
  void onChange(String v) {
    backup = v;
  }

  void onPaseBackupText(String v) {
    backupTextField.currentState?.updateText(v);
  }

  void onChangePassword(String v) {
    password = v;
  }

  void onShowContet() {
    showContet = true;
    updateState();
  }

  final GlobalKey<AppTextFieldState> backupTextField =
      GlobalKey<AppTextFieldState>(debugLabel: "_RestoreBackupViewState");

  bool isValid(String? v) {
    if (v == null) return false;
    return v.trim().length > 100;
  }

  String? bcakupForm(String? v) {
    if (isValid(v)) return null;
    return "bcakup_validator".tr;
  }

  String? passwordForm(String? v) {
    if (v?.isEmpty ?? true) {
      return "backup_password_validator".tr;
    }
    return null;
  }

  String? restored;

  void onRestore() async {
    if (!(form.currentState?.validate() ?? false)) return;
    progressKey.progressText("restoring_backup_please_wait".tr);
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final result = await MethodUtils.call(() async => await wallet.wallet
        .restoreMRTBackup(password: password, backup: backup));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      final keyType = result.result.type;
      bool isCorrectKey = true;
      if (widget.accepted != null) {
        isCorrectKey = (keyType == widget.accepted ||
            keyType.isPrivateKey && widget.accepted!.isPrivateKey);
      }
      if (!isCorrectKey) {
        progressKey.errorText("invalid_backup_type_desc"
            .tr
            .replaceOne(widget.accepted!.value.tr)
            .replaceTwo(keyType.value.tr));
      } else {
        restored = result.result.key;
        page = _Pages.content;
        progressKey.success();
      }
    }
  }

  void onSubmit() {
    if (restored == null) return;
    context.pop(restored);
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.twoSecoundDuration,
      child: (c) => ConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        child: Column(
          children: [
            APPAnimatedSwitcher(enable: page, widgets: {
              _Pages.restore: (c) => _RestoreBackupRestorePage(this),
              _Pages.content: (c) => _RestoreBackupContentPage(this),
            }),
          ],
        ),
      ),
    );
  }
}

class _RestoreBackupContentPage extends StatelessWidget {
  const _RestoreBackupContentPage(this.state, {Key? key}) : super(key: key);
  final _RestoreBackupViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "restore_encrypted_backup".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("backup_restored_desc".tr),
                WidgetConstant.height8,
              ],
            )),
        SecureContentView(
            content: state.restored ?? "test",
            show: state.showContet,
            onTapShow: state.onShowContet,
            contentName: "qr_code".tr),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: state.onSubmit,
                child: Text("submit".tr))
          ],
        )
      ],
    );
  }
}

class _RestoreBackupRestorePage extends StatelessWidget {
  const _RestoreBackupRestorePage(this.state, {Key? key}) : super(key: key);
  final _RestoreBackupViewState state;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          PageTitleSubtitle(
              title: "restore_encrypted_backup".tr,
              body: Text("restore_backup_desc".tr)),
          AppTextField(
            label: "enter_backup".tr,
            validator: state.bcakupForm,
            onChanged: state.onChange,
            key: state.backupTextField,
            minlines: 3,
            maxLines: 5,
            initialValue: state.backup,
            suffixIcon: PasteTextIcon(
              onPaste: state.onPaseBackupText,
              isSensitive: false,
            ),
          ),
          AppTextField(
              label: "input_backup_password".tr,
              validator: state.passwordForm,
              onChanged: state.onChangePassword,
              initialValue: state.password,
              obscureText: true),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: state.onRestore,
                child: Text("restore_backup".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}
