import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/restore_backup.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/wroker/keys/models/imported.dart';
import 'package:mrt_wallet/wroker/keys/models/key_type.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';
import 'package:mrt_wallet/wroker/utils/ripple/ripple.dart';

enum _PrivateKeyTypes {
  extendKey("Extended key"),
  privateKey("Private key"),
  wif("Wif");

  MrtBackupTypes? get backupType {
    switch (this) {
      case _PrivateKeyTypes.extendKey:
        return MrtBackupTypes.extendedKey;
      case _PrivateKeyTypes.privateKey:
        return MrtBackupTypes.privatekey;
      case _PrivateKeyTypes.wif:
        return MrtBackupTypes.wif;
      default:
        throw UnimplementedError();
    }
  }

  const _PrivateKeyTypes(this.value);
  final String value;
  bool get isExtendedKey => this == _PrivateKeyTypes.extendKey;
  bool get supportedBackup => this != _PrivateKeyTypes.wif;
  CustomKeyType toCustomKeyType() {
    if (this == _PrivateKeyTypes.extendKey) return CustomKeyType.extendedKey;
    return CustomKeyType.privateKey;
  }

  String toKey(Bip32Base key) {
    if (isExtendedKey) return key.privateKey.toExtended;
    return key.privateKey.toHex();
  }

  String get helper {
    switch (this) {
      case _PrivateKeyTypes.extendKey:
        return "enter_extended_key_desc";
      case _PrivateKeyTypes.wif:
        return "enter_wif_key_desc";
      default:
        return "enter_private_key_desc";
    }
  }
}

class ImportAccountView extends StatelessWidget {
  const ImportAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final ImportCustomKeys? importKey = context.getNullArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _ImportAccount(password: password, customKey: importKey);
        },
        title: "import_account".tr,
        subtitle: PageTitleSubtitle(
            title: "import_account".tr, body: Text("import_account_desc1".tr)));
  }
}

class _ImportAccount extends StatefulWidget {
  const _ImportAccount({required this.password, required this.customKey});
  final String password;
  final ImportCustomKeys? customKey;
  @override
  State<_ImportAccount> createState() => _ImportAccountState();
}

class _ImportAccountState extends State<_ImportAccount> with SafeState {
  late final WalletNetwork network;
  final GlobalKey<AppTextFieldState> textFieldState =
      GlobalKey<AppTextFieldState>(debugLabel: "_ImportAccountState");
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_ImportAccountState_1");
  final GlobalKey<AppTextFieldState> backupTextField =
      GlobalKey<AppTextFieldState>(debugLabel: "_ImportAccountState_3");
  final GlobalKey<FormState> form =
      GlobalKey(debugLabel: "_ImportAccountState_2");

  Map<_PrivateKeyTypes, Widget> keyTypes = {};
  bool get inRipple => network.type == NetworkType.xrpl;
  List<CryptoCoins> get coins => network.coins;
  CryptoCoins? coin;
  bool get needSelectCoins => coins.length > 1;

  _PrivateKeyTypes selected = _PrivateKeyTypes.privateKey;
  Bip32Base? _account;
  String? keyName;
  String _key = "";

  void setKeyName(String? name) {
    setState(() {
      keyName = name;
    });
  }

  Map<_PrivateKeyTypes, Widget> _buildKeyTypes() {
    Map<_PrivateKeyTypes, Widget> types = {};
    for (final i in _PrivateKeyTypes.values) {
      if (i == _PrivateKeyTypes.wif && coin!.conf.wifNetVer == null) continue;
      types[i] = OneLineTextWidget(i.value);
    }
    return types;
  }

  void onSelectKeyType(_PrivateKeyTypes? s) {
    selected = s ?? selected;
    _account = null;
    _error = null;
    setState(() {});
  }

  void onChangeKeyAlogrithm(CryptoCoins? mewCoin) {
    if (mewCoin == null) return;
    coin = mewCoin;
    keyTypes = _buildKeyTypes();
    setState(() {});
  }

  void onPaste(String v) {
    textFieldState.currentState?.updateText(v);
  }

  String? _error;

  Future<Bip32Base> _getKey(WalletProvider model) async {
    switch (selected) {
      case _PrivateKeyTypes.extendKey:
        return BlockchainUtils.extendedKeyToBip32(
            extendedKey: _key, coin: coin!);
      case _PrivateKeyTypes.privateKey:
        if (inRipple) {
          return RippleUtils.ripplePrivateKeyToBip32(_key, coin!);
        }
        return BlockchainUtils.privteKeyToBip32(
            BytesUtils.fromHexString(_key), coin!);
      case _PrivateKeyTypes.wif:
        return BlockchainUtils.wifToBip32(_key, coin!);
      default:
        throw WalletExceptionConst.dataVerificationFailed;
    }
  }

  String? validate(String? v) {
    if (v == null || v.length < BlockchainConst.minimumKeysLength) {
      return "invalid_key".tr;
    }
    return null;
  }

  void onChangeKey(String key) {
    _key = key;
    if (_error != null) {
      _error = null;
      setState(() {});
    }
  }

  void _init() {
    network = context.watch<WalletProvider>(StateConst.main).network;
    if (!needSelectCoins) {
      coin = coins.first;
      keyTypes = _buildKeyTypes();
    }
    if (widget.customKey != null) {
      final ImportCustomKeys customKey = widget.customKey!;
      if (!coins.contains(customKey.coin)) {
        progressKey.errorText(
            "wrong_network_key_error".tr.replaceOne(network.token.name),
            backToIdle: false);
        return;
      }
      selected = _PrivateKeyTypes.privateKey;
      coin = customKey.coin;
      _key = customKey.privateKey;
    }
    progressKey.success();
  }

  void onRestoreBackup(String? v) {
    if (v == null) return;
    textFieldState.currentState?.updateText(v);
  }

  void onSetup({bool custumKey = false}) async {
    if (!custumKey) {
      if (!(form.currentState?.validate() ?? false)) return;
    }

    progressKey.progressText("importing_key_pls_wait".tr);
    final model = context.watch<WalletProvider>(StateConst.main);

    final createKey = await MethodUtils.call(() async {
      _account = await _getKey(model);
      if (_account == null) {
        _error = "private_key_invalid".tr;
        throw WalletExceptionConst.invalidPrivateKey;
      }
      final customKey = ImportedKeyStorage(
          checksum: BlockchainUtils.createCustomKeyChecksum(_account!),
          extendedPrivateKey: selected.toKey(_account!),
          coin: coin!,
          publicKey: _account!.publicKey.toHex(),
          name: keyName,
          keyType: selected.toCustomKeyType());
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => _init());
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      initialStatus: StreamWidgetStatus.progress,
      initialWidget: ProgressWithTextView(text: "retrieving_resources".tr),
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
                  if (needSelectCoins) ...[
                    Text("coin_type".tr, style: context.textTheme.titleMedium),
                    Text("choose_key_coin_desc".tr),
                    WidgetConstant.height8,
                    AppDropDownBottom(
                        items: {
                          for (final i in coins)
                            i: RichText(
                                text: TextSpan(
                                    style: context.textTheme.bodyMedium,
                                    children: [
                                  TextSpan(text: i.coinName),
                                  TextSpan(
                                      text: " (${i.proposal.specName}) ",
                                      style: context.textTheme.labelSmall)
                                ]))
                        },
                        value: coin,
                        label: "coin_type".tr,
                        onChanged: onChangeKeyAlogrithm),
                    WidgetConstant.height20,
                  ],
                  APPAnimatedSize(
                      isActive: coin != null,
                      onActive: (c) => _ImportAccountStateKeyType(this),
                      onDeactive: (c) => WidgetConstant.sizedBox)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportAccountStateKeyType extends StatelessWidget {
  const _ImportAccountStateKeyType(this.state, {Key? key}) : super(key: key);
  final _ImportAccountState state;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("key_type".tr, style: context.textTheme.titleMedium),
      Text("inidicate_type_of_key".tr),
      WidgetConstant.height8,
      AppDropDownBottom(
          items: state.keyTypes,
          value: state.selected,
          label: "key_type".tr,
          onChanged: state.onSelectKeyType),
      WidgetConstant.height20,
      _ImportAccountStateKey(state: state)
    ]);
  }
}

class _ImportAccountStateKey extends StatelessWidget {
  const _ImportAccountStateKey({required this.state, Key? key})
      : super(key: key);
  final _ImportAccountState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.selected.value, style: context.textTheme.titleMedium),
        Text(state.selected.helper.tr),
        WidgetConstant.height8,
        AppTextField(
            key: state.textFieldState,
            label: state.selected.value,
            onChanged: state.onChangeKey,
            initialValue: state._key,
            validator: state.validate,
            suffixIcon:
                PasteTextIcon(onPaste: state.onPaste, isSensitive: true),
            error: state._error,
            obscureText: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
                onPressed: () {
                  context
                      .openSliverBottomSheet<String>("restore_backup".tr,
                          child: RestoreBackupView(
                              accepted: state.selected.backupType))
                      .then(state.onRestoreBackup);
                },
                icon: const Icon(Icons.restore),
                label: Text("restore_backup".tr))
          ],
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
                    defaultValue: state.keyName,
                    regExp: APPConst.keyNameRegex,
                    title: PageTitleSubtitle(
                        title: "key_name".tr,
                        body: Text("import_private_key_key_name_desc".tr)),
                    buttonText: "setup_input".tr,
                    label: "key_name".tr,
                  ),
                )
                .then(state.setKeyName);
          },
          onRemoveIcon: state.keyName == null
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          child: Text(state.keyName?.orEmpty ?? "tap_to_input_value".tr,
              maxLines: 3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: state.onSetup,
              child: Text("import_account".tr),
            ),
          ],
        )
      ],
    );
  }
}
