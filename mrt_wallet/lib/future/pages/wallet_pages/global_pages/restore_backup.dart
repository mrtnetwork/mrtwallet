import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/secret_wallet/web3_storage_defination.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/widgets/secure_content_view.dart';

enum _Pages { restore, content }

class RestoreBackupView extends StatefulWidget {
  const RestoreBackupView({Key? key}) : super(key: key);

  @override
  State<RestoreBackupView> createState() => _RestoreBackupViewState();
}

class _RestoreBackupViewState extends State<RestoreBackupView> with SafeState {
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_RestoreBackupViewState");
  final GlobalKey<FormState> form =
      GlobalKey(debugLabel: "_RestoreBackupViewState_2");
  SecretWalletEncoding encoding = SecretWalletEncoding.json;
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

  String? bcakupValidator(String? v) {
    if (isValid(v)) return null;
    return "bcakup_validator".tr;
  }

  void onChangeEncoding(SecretWalletEncoding? updateEncoding) {
    encoding = updateEncoding ?? encoding;
    setState(() {});
  }

  String? passwordValidator(String? v) {
    if (v?.isEmpty ?? true) {
      return "backup_password_validator".tr;
    }
    return null;
  }

  String? restored;

  void onRestore() async {
    if (!(form.currentState?.validate() ?? false)) return;
    progressKey.progressText("restoring_backup_please_wait".tr);
    final result = await MethodCaller.call(() async =>
        await BlockchainUtils.restoreBackup(
            backup: backup, encoding: encoding, password: password));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      restored = result.result;
      page = _Pages.content;
      progressKey.success();
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
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => ConstraintsBoxView(
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
          contentName: "qr_code".tr,
        ),
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
          DropdownButtonFormField<SecretWalletEncoding>(
            value: state.encoding,
            decoration: InputDecoration(
                label: Text("decoding_type".tr),
                helperStyle: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.error),
                helperMaxLines: 3),
            items: SecretWalletEncoding.values.map((enc) {
              return DropdownMenuItem<SecretWalletEncoding>(
                value: enc,
                child: Text(enc.name.camelCase),
              );
            }).toList(),
            onChanged: state.onChangeEncoding,
          ),
          WidgetConstant.height20,
          AppTextField(
            label: "enter_backup".tr,
            validator: state.bcakupValidator,
            onChanged: state.onChange,
            key: state.backupTextField,
            minlines: 3,
            maxLines: 5,
            initialValue: state.backup,
            suffixIcon: PasteTextIcon(onPaste: state.onPaseBackupText),
          ),
          AppTextField(
              label: "input_backup_password".tr,
              validator: state.passwordValidator,
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
