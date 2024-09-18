import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/wallet/setup/setup.dart';
import 'package:blockchain_utils/utils/compare/compare.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

enum _MnemonicOption { import, generate }

enum _MnemonicPage {
  import,
  generate,
  importKey,
  viewMnemonic,
  verifyMnemonic;

  static _MnemonicPage fromOption(_MnemonicOption option) {
    return values.firstWhere((element) => element.name == option.name);
  }
}

class GenerateTonMnemonicView extends StatelessWidget {
  const GenerateTonMnemonicView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<TheOpenNetworkChain>(
      title: "ton_mnemonic".tr,
      childBulder: (wallet, chain, switchAccount) {
        return _GenerateTonMnemonicView(
            network: chain.network.toNetwork(), wallet: wallet);
      },
    );
  }
}

class _GenerateTonMnemonicView extends StatefulWidget {
  const _GenerateTonMnemonicView({
    Key? key,
    required this.network,
    required this.wallet,
  }) : super(key: key);
  final WalletTonNetwork network;
  final WalletProvider wallet;

  @override
  State<_GenerateTonMnemonicView> createState() =>
      __GenerateTonMnemonicViewState();
}

class __GenerateTonMnemonicViewState extends State<_GenerateTonMnemonicView> {
  bool hasPassword = false;
  bool validateTonMnemonic = true;
  bool showKeys = false;
  bool showMnemonic = false;
  final GlobalKey<AppTextFieldState> passwordKey = GlobalKey<AppTextFieldState>(
      debugLabel: "__GenerateTonMnemonicViewState");
  final GlobalKey<AppTextFieldState> mnemonicKey = GlobalKey<AppTextFieldState>(
      debugLabel: "__GenerateTonMnemonicViewState_1");
  final GlobalKey<NumberTextFieldState> mnemonicWordsKey =
      GlobalKey<NumberTextFieldState>(
          debugLabel: "__GenerateTonMnemonicViewState_2");
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  _MnemonicOption option = _MnemonicOption.import;
  _MnemonicPage? page;
  String mnemonic = "";
  List<String> mnemonicList = [];
  String? password;

  ImportCustomKeys? keyPair;

  void onChangeOption(_MnemonicOption? op) {
    option = op ?? option;
    setState(() {});
  }

  void onChangePassword(bool? v) {
    hasPassword = !hasPassword;
    if (!hasPassword) {
      passwordKey.currentState?.clear();
      password = null;
    }
    setState(() {});
  }

  String? validator(String? v) {
    if (v?.isEmpty ?? true) {
      return "password_empty_validator".tr;
    }
    return null;
  }

  void onTapContinue() {
    if (formKey.currentState?.validate() ?? false) {
      if (hasPassword) {
        password = passwordKey.currentState!.getValue();
        if (password!.isEmpty) return;
      }
      page = _MnemonicPage.fromOption(option);
      setState(() {});
    }
  }

  String? mnemonicLengthForm(String? v) {
    if (TonUtils.isValidTonMnemonicLength(v)) return null;
    return "enter_mnemonic_desc3".tr;
  }

  void onPasteMnemonic(String v) {
    mnemonicKey.currentState?.updateText(v);
  }

  void onCheckValidateTonMnemonic(bool? _) {
    validateTonMnemonic = !validateTonMnemonic;
    setState(() {});
  }

  void onChangeShowKeys() {
    showKeys = !showKeys;
    setState(() {});
  }

  void onChangeShowMnemonic() {
    showMnemonic = !showMnemonic;
    setState(() {});
  }

  String? onValidateMnemonic(String? v) {
    final int? count = int.tryParse(v ?? "");
    if (count == null ||
        count < TonConst.minTonMnemonicWords ||
        count > TonConst.maxTonMnemonicWords) {
      return "ton_mnemonic_words_length_validator".tr;
    }
    return null;
  }

  void tapOnVerifyMnemonic() {
    page = _MnemonicPage.verifyMnemonic;
    setState(() {});
  }

  void verifyMnemonic(List<String> mnemonic) {
    if (CompareUtils.iterableIsEqual(mnemonic, mnemonicList)) {
      _generatePrivateKey();
    }
  }

  void generateMnemonic() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final int? wordsNum = mnemonicWordsKey.currentState?.getValue();
    if (wordsNum == null) return;
    progressKey.progressText("generating_mnemonic".tr);
    final result = await MethodUtils.call(() async => widget.wallet.wallet
        .cryptoRequest(TonMenmonicGenerateMessage(
            password: password, wordsNum: wordsNum)));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      mnemonic = result.result;
      mnemonicList = BlockchainUtils.normalizeMnemonic(mnemonic);
      page = _MnemonicPage.viewMnemonic;
      progressKey.success();
    }
  }

  void generatePrivateKey() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    mnemonic = mnemonicKey.currentState?.getValue() ?? "";
    mnemonicList = BlockchainUtils.normalizeMnemonic(mnemonic);
    _generatePrivateKey();
  }

  void _generatePrivateKey() async {
    if (formKey.currentState?.validate() ?? false) {
      progressKey.progressText("validating_mnemonic".tr);
      final result = await MethodUtils.call(
          () async => BlockchainUtils.validateMnemonicWords(mnemonicList));
      if (result.hasError) {
        progressKey.errorText(result.error!.tr);
      } else {
        progressKey.progressText("generating_private_key".tr);
        final key = await MethodUtils.call<ImportCustomKeys>(
          () async {
            return await widget.wallet.wallet.cryptoRequest(
                TonMnemonicToPrivateKeyMessage(
                    mnemonic: mnemonicList.join(" "),
                    password: password,
                    validateTonMnemonic: validateTonMnemonic,
                    coin: widget.network.coins.first));
          },
        );
        if (key.hasError) {
          progressKey.errorText(result.error?.tr ?? "");
        } else {
          keyPair = key.result;
          page = _MnemonicPage.importKey;
          progressKey.success();
        }
      }
    }
  }

  void onBackButton() {
    switch (page) {
      case _MnemonicPage.viewMnemonic:
      case _MnemonicPage.verifyMnemonic:
        mnemonic = '';
        mnemonicList.clear();
        page = _MnemonicPage.generate;
        showMnemonic = false;
        break;
      case _MnemonicPage.importKey:
        keyPair = null;
        page = _MnemonicPage.fromOption(option);
        break;
      case _MnemonicPage.import:
      case _MnemonicPage.generate:
        mnemonic = '';
        mnemonicList.clear();
        page = null;
        break;
      default:
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: page == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          onBackButton();
        }
      },
      child: PageProgress(
        key: progressKey,
        backToIdle: APPConst.oneSecoundDuration,
        child: (c) => ConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: APPAnimatedSwitcher(
                enable: page,
                widgets: {
                  null: (context) => _TonMnemonicChooseOptionPage(state: this),
                  _MnemonicPage.import: (context) =>
                      _TonMnemonicImportMnemonic(state: this),
                  _MnemonicPage.importKey: (context) =>
                      ImportCustomKeyToWalletView(keypair: keyPair!),
                  _MnemonicPage.generate: (context) =>
                      _TonMnemonicGeneratePage(state: this),
                  _MnemonicPage.viewMnemonic: (context) =>
                      _GenerateMnemonicView(state: this),
                  _MnemonicPage.verifyMnemonic: (context) =>
                      _VerifyMnemonicView(state: this)
                },
              ),
            )),
      ),
    );
  }
}

class _VerifyMnemonicView extends StatelessWidget {
  const _VerifyMnemonicView({required this.state, Key? key}) : super(key: key);
  final __GenerateTonMnemonicViewState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerifyMnemonicView(
            mnemonic: state.mnemonicList,
            onValidate: state.verifyMnemonic,
            submitText: "generate_private_key".tr,
          )
        ],
      ),
    );
  }
}

class _GenerateMnemonicView extends StatelessWidget {
  const _GenerateMnemonicView({required this.state, Key? key})
      : super(key: key);
  final __GenerateTonMnemonicViewState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageTitleSubtitle(
              title: "show_mnemonic".tr,
              body: LargeTextView(
                  ["show_mnemonic_desc".tr, "p_note3".tr, "p_note4".tr])),
          Stack(
            children: [
              MnemonicView(mnemonic: state.mnemonicList),
              Positioned.fill(
                child:
                    APPAnimatedSwitcher(enable: state.showMnemonic, widgets: {
                  true: (context) => WidgetConstant.sizedBox,
                  false: (context) => SizedBox.expand(
                        child: Container(
                          decoration: BoxDecoration(
                              color: context.colors.secondary,
                              borderRadius: WidgetConstant.border8),
                          child: Center(
                            child: FilledButton.icon(
                                onPressed: state.onChangeShowMnemonic,
                                icon: const Icon(Icons.remove_red_eye),
                                label: Text("show_mnemonic".tr)),
                          ),
                        ),
                      )
                }),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: state.tapOnVerifyMnemonic,
                child: Text("v_mnemonic".tr),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _TonMnemonicGeneratePage extends StatelessWidget {
  const _TonMnemonicGeneratePage({required this.state, Key? key})
      : super(key: key);
  final __GenerateTonMnemonicViewState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageTitleSubtitle(
            title: "generate_ton_mnemonic".tr,
            body: LargeTextView(
              [
                "ton_mnemonic_desc2".tr,
                "ton_mnemonic_words_desc".tr,
                "p_note3".tr,
                "p_note4".tr,
              ],
              maxLine: 6,
            ),
          ),
          NumberTextField(
            label: "n_of_mnemonic_words".tr,
            onChange: (p0) {},
            defaultValue: TonConst.defaultTonMnemonicWordsLength,
            validator: state.onValidateMnemonic,
            max: TonConst.maxTonMnemonicWords,
            min: TonConst.minTonMnemonicWords,
            key: state.mnemonicWordsKey,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: state.generateMnemonic,
              child: Text("generate_mnemonic".tr),
            )
          ])
        ],
      ),
    );
  }
}

class _TonMnemonicChooseOptionPage extends StatelessWidget {
  const _TonMnemonicChooseOptionPage({required this.state, Key? key})
      : super(key: key);
  final __GenerateTonMnemonicViewState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "ton_mnemonic".tr,
              body: Column(
                children: [
                  Text("ton_mnemonic_desc".tr),
                  WidgetConstant.height8,
                  Text("ton_mnemonic_desc2".tr),
                ],
              )),
          AppSwitchListTile(
            value: state.hasPassword,
            onChanged: state.onChangePassword,
            title: Text(
              "mnemonic_password".tr,
              style: context.textTheme.titleMedium,
            ),
            subtitle: Text("mnemonic_password_desc".tr),
            contentPadding: EdgeInsets.zero,
            maxLine: 4,
          ),
          APPAnimatedSize(
            isActive: state.hasPassword,
            onActive: (p0) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height8,
                AppTextField(
                  obscureText: true,
                  key: state.passwordKey,
                  label: "mnemonic_password".tr,
                  validator: state.validator,
                  initialValue: state.password,
                ),
              ],
            ),
            onDeactive: (p0) => WidgetConstant.sizedBox,
          ),
          WidgetConstant.height20,
          Text("create_import_mnemonic".tr,
              style: context.textTheme.titleMedium),
          Text("choose_an_action".tr),
          WidgetConstant.height8,
          ...List.generate(
            _MnemonicOption.values.length,
            (index) => RadioListTile(
              value: _MnemonicOption.values[index],
              groupValue: state.option,
              title: Text(_MnemonicOption.values[index].name.tr),
              onChanged: state.onChangeOption,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: state.onTapContinue,
                child: Text("continue".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TonMnemonicImportMnemonic extends StatelessWidget {
  const _TonMnemonicImportMnemonic({required this.state, Key? key})
      : super(key: key);
  final __GenerateTonMnemonicViewState state;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageTitleSubtitle(
            title: "enter_mnemonic".tr,
            body: LargeTextView(
              ["enter_mnemonic_desc3".tr],
            ),
          ),
          AppTextField(
            label: "enter_mne".tr,
            key: state.mnemonicKey,
            validator: state.mnemonicLengthForm,
            minlines: 3,
            initialValue: state.mnemonic,
            suffixIcon: PasteTextIcon(
                onPaste: state.onPasteMnemonic, isSensitive: false),
          ),
          WidgetConstant.height20,
          AppCheckListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("validate_ton_mnemonic".tr,
                style: context.textTheme.titleMedium),
            subtitle: Text("validate_ton_mnemonic_desc".tr),
            value: state.validateTonMnemonic,
            onChanged: state.onCheckValidateTonMnemonic,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: state.generatePrivateKey,
                child: Text("generate_private_key".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// class _ImportToWalletKey extends StatelessWidget {
//   const _ImportToWalletKey({required this.state, Key? key}) : super(key: key);
//   final __GenerateTonMnemonicViewState state;
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           PageTitleSubtitle(
//               title: "import_private_key".tr,
//               body: Text("import_private_key_desc".tr)),
//           Text("private_key".tr, style: context.textTheme.titleMedium),
//           WidgetConstant.height8,
//           Stack(
//             children: [
//               Container(
//                 foregroundDecoration: state.showKeys
//                     ? null
//                     : BoxDecoration(
//                         color: context.colors.secondary,
//                         borderRadius: WidgetConstant.border8,
//                       ),
//                 child: ContainerWithBorder(
//                     child: CopyTextWithBarcode(
//                   secureBarcode: true,
//                   barcodeWidget: ContainerWithBorder(
//                       child: CopyTextIcon(
//                           dataToCopy: state.privateKey!,
//                           widget:
//                               ObscureTextView(state.privateKey!, maxLine: 3))),
//                   underBarcodeWidget: ErrorTextContainer(
//                       margin: WidgetConstant.paddingVertical10,
//                       error: "image_store_alert_keys".tr),
//                   dataToCopy: state.privateKey!,
//                   barcodeTitle: "private_key".tr,
//                   widget: SelectableText(state.privateKey!),
//                 )),
//               ),
//               Positioned.fill(
//                 child: APPAnimatedSwitcher(enable: state.showKeys, widgets: {
//                   true: (context) => WidgetConstant.sizedBox,
//                   false: (context) => FilledButton.icon(
//                       onPressed: state.onChangeShowKeys,
//                       icon: const Icon(Icons.remove_red_eye),
//                       label: Text("show_private_key".tr))
//                 }),
//               )
//             ],
//           ),
//           WidgetConstant.height20,
//           Text("publick_key".tr, style: context.textTheme.titleMedium),
//           WidgetConstant.height8,
//           ContainerWithBorder(
//               child: CopyTextWithBarcode(
//             secureBarcode: false,
//             barcodeWidget: ContainerWithBorder(
//                 child: CopyTextIcon(
//                     dataToCopy: state.publicKey!,
//                     widget: Text(state.publicKey!))),
//             dataToCopy: state.publicKey!,
//             barcodeTitle: "publick_key".tr,
//             widget: SelectableText(state.publicKey!),
//           )),
//           WidgetConstant.height20,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               FixedElevatedButton(
//                 onPressed: () {
//                   context.to(PageRouter.importAccount, argruments: key);
//                 },
//                 child: Text("import_to_wallet".tr),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
