import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
// import 'package:xrpl_dart/xrpl_dart.dart';

enum _PrivateKeyTypes {
  extendKey("Extended key"),
  privateKey("Private key"),
  wif("Wif"),
  rippleSeed("Ripple seed"),
  rippleEntropy("Ripple entropy"),
  backup("Backup");

  const _PrivateKeyTypes(this.value);
  final String value;
  bool get forRipple =>
      this == _PrivateKeyTypes.rippleEntropy ||
      this == _PrivateKeyTypes.rippleSeed;
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
  late Map<_PrivateKeyTypes, Widget> keyTypes = _buildKeyTypes();
  String? keyName;
  void setKeyName(String? name) {
    setState(() {
      keyName = name;
    });
  }

  bool get inRipple => widget.network is AppXRPNetwork;
  late EllipticCurveTypes curve = widget.network.keyTypes.first;
  List<EllipticCurveTypes> get curves => widget.network.keyTypes;
  late final bool needSelectCurve = curves.length > 1;

  Map<_PrivateKeyTypes, Widget> _buildKeyTypes() {
    Map<_PrivateKeyTypes, Widget> types = {};
    for (final i in _PrivateKeyTypes.values) {
      if (i == _PrivateKeyTypes.wif &&
          !widget.network.coins
              .any((element) => element.conf.wifNetVer != null)) continue;

      if (i.forRipple) {
        if (!inRipple) continue;
      }
      types[i] = OneLineTextWidget(i.value);
    }
    return types;
  }

  _PrivateKeyTypes selected = _PrivateKeyTypes.privateKey;

  Bip32Base? _account;

  bool get isBackup => selected == _PrivateKeyTypes.backup;

  void onSelect(_PrivateKeyTypes? s) {
    selected = s ?? selected;
    _account = null;
    _error = null;
    // showRippleKeyAlgorithm = _showRippleKeyAlgorithm();
    setState(() {});
  }

  void onSelectRippleKeyAlgorithm(EllipticCurveTypes? alg) {
    curve = alg ?? curve;
    setState(() {});
  }

  void onPaste(String v) {
    textFieldState.currentState?.updateText(v);
  }

  String? _error;

  Future<Bip32Base> _getKey(WalletProvider model) async {
    final coin = widget.network.coins.first;

    switch (selected) {
      case _PrivateKeyTypes.extendKey:
        return BlockchainUtils.extendedKeyToBip32(_key, coin.conf.type);
      case _PrivateKeyTypes.privateKey:
        if (inRipple) {
          return RippleUtils.ripplePrivateKeyToBip32(_key, curve);
        }
        return BlockchainUtils.privteKeyToBip32(
            BytesUtils.fromHexString(_key), coin.conf.type);
      case _PrivateKeyTypes.wif:
        return BlockchainUtils.wifToBip32(_key, coin);
      case _PrivateKeyTypes.backup:
        final backupResult = BytesUtils.toHexString(
            await model.restoreBackup(_password, _backup, encoding));
        if (inRipple) {
          return RippleUtils.ripplePrivateKeyToBip32(backupResult, curve);
        }
        return BlockchainUtils.privteKeyToBip32(
            BytesUtils.fromHexString(backupResult), coin.conf.type);
      case _PrivateKeyTypes.rippleSeed:
        return RippleUtils.rippleSeedToBip32(_key);
      case _PrivateKeyTypes.rippleEntropy:
        return RippleUtils.rippleEntropyToBip32(_key, curve);
      default:
        throw UnimplementedError();
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
          publicKey: _account!.publicKey.toHex(),
          name: keyName);
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
          alignment: Alignment.center,
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
                  Text("key_type".tr, style: context.textTheme.titleMedium),
                  Text("inidicate_type_of_key".tr),
                  WidgetConstant.height8,
                  AppDropDownBottom(
                      items: keyTypes,
                      value: selected,
                      label: "key_type".tr,
                      onChanged: onSelect),
                  WidgetConstant.height20,
                  if (needSelectCurve) ...[
                    Text("ripple_key_type".tr,
                        style: context.textTheme.titleMedium),
                    Text("inidicate_type_of_key".tr),
                    WidgetConstant.height8,
                    AppDropDownBottom(
                        items: {
                          for (final i in curves) i: Text(i.name.camelCase)
                        },
                        value: curve,
                        label: "ripple_key_type".tr,
                        onChanged: onSelectRippleKeyAlgorithm),
                    WidgetConstant.height20,
                  ],
                  Text(selected.value, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
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
                      label: selected.value,
                      onChanged: onChangeKey,
                      initialValue: _key,
                      validator: validate,
                      minlines: 2,
                      suffixIcon: PasteTextIcon(onPaste: onPaste),
                      error: _error,
                      helperText: "import_account_desc2".tr,
                    ),
                  WidgetConstant.height20,
                  Text("key_name".tr, style: context.textTheme.titleMedium),
                  Text("import_private_key_key_name_desc".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<String>(
                            "import_account".tr,
                            child: StringWriterView(
                              defaultValue: keyName,
                              regExp: AppGlobalConst.keyNameRegex,
                              title: PageTitleSubtitle(
                                  title: "key_name".tr,
                                  body: Text(
                                      "import_private_key_key_name_desc".tr)),
                              buttomText: "setup_input".tr,
                              label: "key_name".tr,
                            ),
                          )
                          .then(setKeyName);
                    },
                    onRemoveIcon: keyName == null
                        ? const Icon(Icons.edit)
                        : const Icon(Icons.add),
                    child: Text(keyName?.orEmpty ?? "tap_to_input_value".tr,
                        maxLines: 3),
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
