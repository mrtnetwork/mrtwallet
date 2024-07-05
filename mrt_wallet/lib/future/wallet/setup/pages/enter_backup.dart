import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/secret_wallet/web3_storage_defination.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';

enum _BackupMode { mnemonicBackup, walletBackup }

enum _BackupPage { fields, verify }

class EnterMnemonicBackupView extends StatefulWidget {
  const EnterMnemonicBackupView({super.key});

  @override
  State<EnterMnemonicBackupView> createState() =>
      _EnterMnemonicBackupViewState();
}

class _EnterMnemonicBackupViewState extends State<EnterMnemonicBackupView>
    with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "EnterMnemonicBackupView_1");
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> backupTextField =
      GlobalKey<AppTextFieldState>(debugLabel: "EnterMnemonicBackupView_2");
  _BackupMode selectedMode = _BackupMode.mnemonicBackup;
  _BackupPage page = _BackupPage.fields;
  void onChangeBackupMode(_BackupMode? v) {
    selectedMode = v ?? selectedMode;
    setState(() {});
  }

  late final Map<_BackupMode, Widget> backupModes = {
    _BackupMode.mnemonicBackup: Text("mnemonic_backup".tr),
    _BackupMode.walletBackup: Text("wallet_backup".tr)
  };
  String _backup = "";
  String _passphrase = "";
  bool passphrase = false;
  String? _error;
  SecretWalletEncoding encoding = SecretWalletEncoding.json;

  WalletRestoreV2? restoredBackup;

  void onChangeEncoding(SecretWalletEncoding? updateEncoding) {
    encoding = updateEncoding ?? encoding;

    setState(() {});
  }

  void usePassphrase(bool? v) {
    passphrase = v ?? passphrase;
    _passphrase = "";
    setState(() {});
  }

  void onChangePassphrase(String v) {
    _passphrase = v;
  }

  void onChange(String v) {
    _backup = v;
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  bool isValid(String? v) {
    if (v == null) return false;
    return v.trim().length > 100;
  }

  String? bcakupForm(String? v) {
    if (isValid(v)) return null;
    return "bcakup_validator".tr;
  }

  String _backupPassword = "";
  void onChangeBackupPassword(String password) {
    _backupPassword = password;
  }

  String? passwordForm(String? v) {
    if (v?.isEmpty ?? true) {
      return "backup_password_validator".tr;
    }
    return null;
  }

  void onPaseBackupText(String v) {
    backupTextField.currentState?.updateText(v);
  }

  void onSetupBackup() {
    if (restoredBackup == null) return;
    final model = context.watch<SetupWalletController>("setup_wallet");
    model.setupBackup(restoredBackup!);
  }

  void setup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final model = context.watch<SetupWalletController>("setup_wallet");
    progressKey.progressText("decrypting_backup_please_wait".tr);
    final result = await MethodUtils.call(() async {
      final walletProvider = context.watch<WalletProvider>(StateConst.main);
      return await walletProvider.restoreKeysBackup(
          password: _backupPassword, backup: _backup, encoding: encoding);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
      return;
    }
    if (selectedMode == _BackupMode.mnemonicBackup) {
      progressKey.progressText("generating_wallet_please_wait".tr);
      final generateWalletResult = await MethodUtils.call(() async {
        final toString = StringUtils.tryDecode(result.result);
        BlockchainUtils.validateMnemonic(toString ?? "");
        final Mnemonic exitingMnemonic = Mnemonic.fromString(toString!);
        final String? mnemonicPassphrase = passphrase ? _passphrase : null;
        await model.setup(mnemonicPassphrase, exitingMnemonic: exitingMnemonic);
      });
      if (generateWalletResult.hasError) {
        progressKey.errorText(generateWalletResult.error!.tr);
      }
    } else {
      progressKey.progressText("verifying_backup_please_wait".tr);
      final restoreWalletResult = await MethodUtils.call(() async {
        final String? passPhrase = passphrase ? _passphrase : null;
        return await model.restoreWalletBackup(result.result,
            passphrase: passPhrase);
      });
      if (restoreWalletResult.hasError) {
        progressKey.errorText(restoreWalletResult.error!.tr);
      } else {
        restoredBackup = restoreWalletResult.result;
        page = _BackupPage.verify;
        progressKey.success();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      backToIdle: APPConst.animationDuraion,
      key: progressKey,
      child: () => APPAnimatedSwitcher(enable: page, widgets: {
        _BackupPage.fields: (c) => _BackupFieldsWidget(this),
        _BackupPage.verify: (c) => _BackupVerifyReview(this),
      }),
    );
  }
}

class _BackupVerifyReview extends StatelessWidget {
  const _BackupVerifyReview(this.state, {Key? key}) : super(key: key);
  final _EnterMnemonicBackupViewState state;
  WalletRestoreV2 get backup => state.restoredBackup!;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
            title: "verification_backup_review".tr,
            body: Text("verification_backup_desc".tr),
          ),
          Text("status".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemove: () {},
            onTapWhenOnRemove: false,
            onRemoveWidget: _BackupStatusIcon(backup.verifiedChecksum),
            child: _BackupStatusText(backup.verifiedChecksum),
          ),
          if (backup.verifiedChecksum != false) ...[
            WidgetConstant.height20,
            Text("total_accounts".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ContainerWithBorder(
              child: Text(backup.totalAccounts.toString(),
                  style: context.textTheme.bodyLarge),
            ),
            if (backup.hasFailedAccount) ...[
              WidgetConstant.height20,
              Text("unverified_account".tr,
                  style: context.textTheme.titleMedium),
              Text("unverified_account_desc".tr),
              WidgetConstant.height8,
              ContainerWithBorder(
                child: Column(
                  children: List.generate(
                      backup.invalidAddresses.length,
                      (i) => ContainerWithBorder(
                          backgroundColor: context.colors.onPrimaryContainer,
                          child: AddressDetailsView(
                            address: backup.invalidAddresses[0],
                            color: context.colors.primaryContainer,
                            showBalance: false,
                          ))),
                ),
              )
            ],
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: state.onSetupBackup,
                child: Text("setup".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _BackupStatusIcon extends StatelessWidget {
  const _BackupStatusIcon(this.verify, {Key? key}) : super(key: key);
  final bool? verify;
  @override
  Widget build(BuildContext context) {
    switch (verify) {
      case true:
        return Icon(Icons.check_circle, color: context.colors.green);
      case false:
        return Icon(Icons.error, color: context.colors.error);
      default:
        return Icon(Icons.question_mark_sharp, color: context.colors.orange);
    }
  }
}

class _BackupStatusText extends StatelessWidget {
  const _BackupStatusText(this.verify, {Key? key}) : super(key: key);
  final bool? verify;
  @override
  Widget build(BuildContext context) {
    switch (verify) {
      case true:
        return Text("backup_verification_success_desc".tr);
      case false:
        return Text("backup_verification_failed_desc".tr);
      default:
        return Text("unsuported_legacy_backup".tr);
    }
  }
}

class _BackupFieldsWidget extends StatelessWidget {
  const _BackupFieldsWidget(this.state, {Key? key}) : super(key: key);
  final _EnterMnemonicBackupViewState state;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: state.form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
            title: "restore_mnemonic_from_bcakup".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("restore_mnemonic_desc".tr),
              ],
            ),
          ),
          AppDropDownBottom(
            items: state.backupModes,
            label: "select_backup_option".tr,
            onChanged: state.onChangeBackupMode,
            value: state.selectedMode,
          ),
          WidgetConstant.height20,
          DropdownButtonFormField<SecretWalletEncoding>(
            value: state.encoding,
            decoration: InputDecoration(
                label: Text("decoding_type".tr),
                helperText: state._error,
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
          WidgetConstant.height8,
          AppTextField(
            label: "enter_backup".tr,
            validator: state.bcakupForm,
            onChanged: state.onChange,
            key: state.backupTextField,
            minlines: 3,
            maxLines: 5,
            initialValue: state._backup,
            suffixIcon: PasteTextIcon(
                onPaste: state.onPaseBackupText, isSensitive: false),
          ),
          AppTextField(
            label: "input_backup_password".tr,
            validator: state.passwordForm,
            onChanged: state.onChangeBackupPassword,
            initialValue: state._backupPassword,
            error: state._error,
            obscureText: true,
          ),
          WidgetConstant.height20,
          Text("mn_password".tr, style: context.textTheme.titleMedium),
          Text("enter_passphrase_desc".tr),
          WidgetConstant.height8,
          AppSwitchListTile(
            title: Text("passphrase".tr),
            value: state.passphrase,
            onChanged: state.usePassphrase,
            subtitle: Text("enable_mnemonic_password".tr),
          ),
          AnimatedSize(
            duration: APPConst.animationDuraion,
            alignment: Alignment.centerLeft,
            child: !state.passphrase
                ? WidgetConstant.sizedBox
                : Padding(
                    padding: WidgetConstant.paddingHorizontal20,
                    child: Column(
                      children: [
                        WidgetConstant.height8,
                        AppTextField(
                          label: "mn_password".tr,
                          obscureText: true,
                          disableContextMenu: true,
                          initialValue: state._passphrase,
                          onChanged: state.onChangePassphrase,
                          validator: (p0) {
                            if (!state.passphrase) return null;
                            if (p0?.isEmpty ?? true) {
                              return "password_should_not_be_empty".tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: state.setup,
                child: Text("setup".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}
