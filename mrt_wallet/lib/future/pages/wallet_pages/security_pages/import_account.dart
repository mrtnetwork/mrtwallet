import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum _PrivateKeyTypes {
  extendKey("Extended key"),
  privateKey("Private key"),
  wif("Wif"),
  backup("Backup");

  const _PrivateKeyTypes(this.value);
  final String value;
}

class ImportAccountView extends StatelessWidget {
  const ImportAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppNetworkImpl network = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (p0, p1) {
          return _ImportAccount(password: p1, network: network);
        },
        title: "import_account".tr,
        subtitle: PageTitleSubtitle(
            title: "import_account".tr, body: Text("import_account_desc1".tr)));
  }
}

class _ImportAccount extends StatefulWidget {
  const _ImportAccount({required this.password, required this.network});
  final String password;
  final AppNetworkImpl network;
  @override
  State<_ImportAccount> createState() => _ImportAccountState();
}

class _ImportAccountState extends State<_ImportAccount> with SafeState {
  final GlobalKey<AppTextFieldState> textFieldState =
      GlobalKey<AppTextFieldState>(debugLabel: "_ImportAccountState");
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_ImportAccountState_1");
  final GlobalKey<FormState> form =
      GlobalKey(debugLabel: "_ImportAccountState_2");
  late Map<dynamic, String> keyTypes = {
    for (final i in _PrivateKeyTypes.values) i: i.value
  };
  Set<_PrivateKeyTypes> selected = {_PrivateKeyTypes.values[1]};

  Bip32Base? _account;

  bool get isBackup => selected.first == _PrivateKeyTypes.backup;

  void onSelect<T>(Set<T> s) {
    selected = s.cast();
    _account = null;
    _error = null;
    setState(() {});
  }

  void onPaste(String v) {
    textFieldState.currentState?.updateText(v);
  }

  String? _error;

  Future<Bip32Base> _getKey(WalletProvider model) async {
    final coin = widget.network.coins.first;

    switch (selected.first) {
      case _PrivateKeyTypes.extendKey:
        return BlockchainUtils.extendedKeyToBip32(_key, coin.conf.type);
      case _PrivateKeyTypes.privateKey:
        return BlockchainUtils.privteKeyToBip32(
            BytesUtils.fromHexString(_key), coin.conf.type);
      case _PrivateKeyTypes.wif:
        return BlockchainUtils.wifToBip32(_key, coin);
      case _PrivateKeyTypes.backup:
        final backupResult =
            await model.restoreBackup(_password, _backup, encoding);
        return BlockchainUtils.privteKeyToBip32(
            BytesUtils.fromHexString(backupResult), coin.conf.type);
    }
  }

  void onSetup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    progressKey.progressText("importing_key_pls_wait".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);

    final createKey = await MethodCaller.call(() async {
      _account = await _getKey(model);
      if (_account == null) {
        _error = "private_key_invalid".tr;
        throw WalletExceptionConst.invalidPrivateKey;
      }
      final customKey = WalletCustomKeys(
          checksum: _account!.publicKey.fingerPrint.toHex(),
          extendedPrivateKey: _account!.privateKey.toExtended,
          type: _account!.curveType,
          publicKey: _account!.publicKey.toHex());
      return customKey;
    });
    if (createKey.hasError) {
      _error = createKey.error!.tr;
      progressKey.errorText(createKey.error!.tr);
      return;
    }
    final result = await model.importAccount(createKey.result, widget.password);
    if (result.hasError) {
      _error = result.error!.tr;
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("address_imported_desc1".tr, backToIdle: false);
    }
  }

  String? validate(String? v) {
    if (v == null || v.length < EcdsaKeysConst.privKeyByteLen) {
      return "private_key_invalid".tr;
    }
    return null;
  }

  String _key = "";

  void onChangeKey(String key) {
    _key = key;
    if (_error != null) {
      _error = null;
      setState(() {});
    }
  }

  SecretWalletEncoding encoding = SecretWalletEncoding.json;

  void onChangeEncoding(SecretWalletEncoding? updateEncoding) {
    encoding = updateEncoding ?? encoding;

    setState(() {});
  }

  String _password = "";
  void onChangePassword(String password) {
    _password = password;
  }

  final GlobalKey<AppTextFieldState> backupTextField =
      GlobalKey<AppTextFieldState>(debugLabel: "EnterMnemonicBackupView_2");
  String? passwordValidator(String? v) {
    if (v?.isEmpty ?? true) {
      return "backup_password_validator".tr;
    }
    return null;
  }

  void onPaseBackupText(String v) {
    backupTextField.currentState?.updateText(v);
  }

  bool isValid(String? v) {
    if (v == null) return false;
    return v.trim().length > 100;
  }

  String? bcakupValidator(String? v) {
    if (isValid(v)) return null;
    return "bcakup_validator".tr;
  }

  String _backup = "";
  void onChange(String v) {
    _backup = v;
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => UnfocusableChild(
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitleSubtitle(
                      title: "import_account".tr,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("import_account_desc2".tr),
                          WidgetConstant.height8,
                          Text("import_account_desc1".tr),
                        ],
                      )),
                  Text("import_accounts_desc3".tr,
                      style: context.textTheme.titleLarge),
                  WidgetConstant.height8,
                  AppSegmentedButton(
                      items: keyTypes,
                      selected: selected,
                      onChangeSelected: onSelect),
                  WidgetConstant.height20,
                  if (isBackup) ...[
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
                    WidgetConstant.height20,
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
                      onChanged: onChangePassword,
                      initialValue: _password,
                      error: _error,
                      obscureText: true,
                    ),
                  ] else
                    AppTextField(
                      key: textFieldState,
                      label: selected.first.value,
                      onChanged: onChangeKey,
                      initialValue: _key,
                      validator: validate,
                      minlines: 2,
                      suffixIcon: PasteTextIcon(onPaste: onPaste),
                      error: _error,
                      helperText: "import_account_desc2".tr,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical20,
                        onPressed: onSetup,
                        child: Text("import_account".tr),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
