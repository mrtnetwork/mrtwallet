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

enum PrivateKeyTypes {
  extendKey("Extended key"),
  privateKey("Private key"),
  wif("Wif");

  const PrivateKeyTypes(this.value);
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
    for (final i in PrivateKeyTypes.values) i: i.value
  };
  Set<PrivateKeyTypes> selected = {PrivateKeyTypes.values[1]};

  Bip32Base? _account;

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

  Bip32Base? _getKey() {
    try {
      final coin = widget.network.coins.first;

      switch (selected.first) {
        case PrivateKeyTypes.extendKey:
          return BlockchainUtils.extendedKeyToBip32(_key, coin.conf.type);
        case PrivateKeyTypes.privateKey:
          return BlockchainUtils.privteKeyToBip32(
              BytesUtils.fromHexString(_key), coin.conf.type);
        case PrivateKeyTypes.wif:
          return BlockchainUtils.wifToBip32(_key, coin);
      }
    } catch (e) {
      return null;
    }
  }

  void onSetup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    progressKey.progressText("importing_key_pls_wait".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    _account = _getKey();
    if (_account == null) {
      _error = "private_key_invalid".tr;
      progressKey.errorText("private_key_invalid".tr);
      return;
    }
    final customKey = WalletCustomKeys(
        checksum: _account!.publicKey.fingerPrint.toHex(),
        extendedPrivateKey: _account!.privateKey.toExtended,
        type: _account!.curveType,
        publicKey: _account!.publicKey.toHex());
    final result = await model.importAccount(customKey, widget.password);
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
