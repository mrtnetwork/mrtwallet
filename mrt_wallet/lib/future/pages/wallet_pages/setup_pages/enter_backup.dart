import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/keys/wallet_backup.dart';

enum _BackupMode { mnemonicBackup, walletBackup }

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

  final GlobalKey<AppTextFieldState> backupTextField =
      GlobalKey<AppTextFieldState>(debugLabel: "EnterMnemonicBackupView_2");
  _BackupMode selectedMode = _BackupMode.mnemonicBackup;
  void onChangeBackupMode<T>(T? v) {
    selectedMode = (v as _BackupMode?) ?? selectedMode;
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

  String? bcakupValidator(String? v) {
    if (isValid(v)) return null;
    return "bcakup_validator".tr;
  }

  String _backupPassword = "";
  void onChangeBackupPassword(String password) {
    _backupPassword = password;
  }

  String? passwordValidator(String? v) {
    if (v?.isEmpty ?? true) {
      return "backup_password_validator".tr;
    }
    return null;
  }

  void onPaseBackupText(String v) {
    backupTextField.currentState?.updateText(v);
  }

  void setup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final model = context.watch<SetupWalletController>("setup_wallet");
    model.progressKey.progressText("launch_the_wallet".tr);
    final result = await MethodCaller.call(() async {
      final walletProvider = context.watch<WalletProvider>(StateIdsConst.main);
      final decrypt = await walletProvider.restoreBackup(
          _backupPassword, _backup, encoding);
      if (selectedMode == _BackupMode.walletBackup) {
        final backup = await WalletBackup.fromBackup(
            decrypt, passphrase ? _passphrase : '');
        final password = await model.setupBackup(backup);
        final result = await walletProvider.setupBackup(backup, password);
        if (result.hasError) {
          throw result.exception!;
        }
        return;
      }
      BlockchainUtils.validateMnemonic(decrypt);
      final Mnemonic exitingMnemonic = Mnemonic.fromString(decrypt);
      final mnemonic = await model.setup(passphrase ? _passphrase : null,
          exitingMnemonic: exitingMnemonic);
      await walletProvider.setup(mnemonic.$1, mnemonic.$2);
    });
    if (result.hasError) {
      model.progressKey.errorText(result.error!.tr);
    } else {
      model.progressKey.success(backToIdle: false);
      navigatorKey?.currentContext?.popToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
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
            items: backupModes,
            label: "select_backup_option".tr,
            onChanged: onChangeBackupMode,
            value: selectedMode,
          ),
          WidgetConstant.height20,
          DropdownButtonFormField<SecretWalletEncoding>(
            value: encoding,
            decoration: InputDecoration(
                label: Text("decoding_type".tr),
                helperText: _error,
                helperStyle: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.error),
                helperMaxLines: 3),
            items: SecretWalletEncoding.values.map((enc) {
              return DropdownMenuItem<SecretWalletEncoding>(
                value: enc,
                child: Text(enc.name.camelCase),
              );
            }).toList(),
            onChanged: onChangeEncoding,
          ),
          WidgetConstant.height8,
          AppTextField(
            label: "enter_backup".tr,
            validator: bcakupValidator,
            onChanged: onChange,
            key: backupTextField,
            minlines: 3,
            maxLines: 5,
            initialValue: _backup,
            suffixIcon: PasteTextIcon(onPaste: onPaseBackupText),
          ),
          AppTextField(
            label: "input_backup_password".tr,
            validator: passwordValidator,
            onChanged: onChangeBackupPassword,
            initialValue: _backupPassword,
            error: _error,
            obscureText: true,
          ),
          WidgetConstant.height8,
          PageTitleSubtitle(
            title: "mn_password".tr,
            body: Text("enter_passphrase_desc".tr),
          ),
          AppSwitchListTile(
            title: Text("enable_mnemonic_password".tr),
            value: passphrase,
            onChanged: usePassphrase,
          ),
          AnimatedSize(
            duration: AppGlobalConst.animationDuraion,
            alignment: Alignment.centerLeft,
            child: !passphrase
                ? WidgetConstant.sizedBox
                : Padding(
                    padding: WidgetConstant.paddingHorizontal20,
                    child: Column(
                      children: [
                        AppTextField(
                          label: "mn_password".tr,
                          obscureText: true,
                          disableContextMenu: true,
                          initialValue: _passphrase,
                          onChanged: onChangePassphrase,
                          validator: (p0) {
                            if (!passphrase) return null;
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
                padding: WidgetConstant.paddingVertical20,
                onPressed: setup,
                child: Text("setup".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}
