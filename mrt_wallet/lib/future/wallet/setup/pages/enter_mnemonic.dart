import 'package:blockchain_utils/bip/bip/bip39/bip39_mnemonic.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/setup/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class EnterMnemonicView extends StatefulWidget {
  const EnterMnemonicView({super.key});

  @override
  State<EnterMnemonicView> createState() => _EnterMnemonicViewState();
}

class _EnterMnemonicViewState extends State<EnterMnemonicView> with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "EnterMnemonicView_1");
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "EnterMnemonicView_2");
  final GlobalKey<AppTextFieldState> mnemonicController =
      GlobalKey(debugLabel: "EnterMnemonicView_3");

  String _mnemonic = "";
  String _passphrase = "";
  bool passphrase = false;
  String? _error;

  void usePassphrase(bool? v) {
    passphrase = v ?? passphrase;
    _passphrase = "";
    setState(() {});
  }

  void onChangePassphrase(String v) {
    _passphrase = v;
  }

  void onChange(String v) {
    _mnemonic = v;
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  bool isValid(String? mnemonic) {
    if (mnemonic == null) return false;

    final List<String> toList =
        mnemonic.replaceAll(RegExp(r'\s+'), " ").split(" ");
    final wordsCount = Bip39WordsNum.fromValue(toList.length);
    return wordsCount != null;
  }

  String? mnemonicLengthForm(String? v) {
    if (isValid(v)) return null;
    return "enter_mnemonic_validator".tr;
  }

  void setup() async {
    if (!(form.currentState?.validate() ?? false)) return;
    final model = context.watch<SetupWalletController>(StateConst.setup);

    progressKey.progressText("launch_the_wallet".tr);
    final result = await MethodUtils.call(() async {
      BlockchainUtils.validateMnemonic(_mnemonic);
      final Mnemonic exitingMnemonic = Mnemonic.fromString(_mnemonic);
      final String? mnemonicPassphrase = passphrase ? _passphrase : null;
      await model.setup(mnemonicPassphrase, exitingMnemonic: exitingMnemonic);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    }
  }

  void onPasteMnemonic(String v) {
    mnemonicController.currentState?.updateText(v);
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => Form(
        key: form,
        child: Column(
          children: [
            PageTitleSubtitle(
              title: "enter_mnemonic".tr,
              body: LargeTextView(
                [
                  "enter_mnemonic_desc".tr,
                  "enter_mnemonic_desc2".tr,
                ],
              ),
            ),
            AppTextField(
              label: "enter_mne".tr,
              validator: mnemonicLengthForm,
              onChanged: onChange,
              error: _error,
              key: mnemonicController,
              minlines: 3,
              suffixIcon: Column(
                children: [
                  PasteTextIcon(onPaste: onPasteMnemonic, isSensitive: true),
                  BarcodeScannerIconView(onPasteMnemonic, isSensitive: true)
                ],
              ),
              initialValue: _mnemonic,
            ),
            WidgetConstant.height20,
            PageTitleSubtitle(
              title: "mn_password".tr,
              body: LargeTextView(
                ["enter_passphrase_desc".tr, "extra_opetion_desc".tr],
              ),
            ),
            AppSwitchListTile(
              title: Text("enable_mnemonic_password".tr),
              value: passphrase,
              onChanged: usePassphrase,
            ),
            AnimatedSize(
              duration: APPConst.animationDuraion,
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
      ),
    );
  }
}
