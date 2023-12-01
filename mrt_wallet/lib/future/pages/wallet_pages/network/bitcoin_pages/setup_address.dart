import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

enum AddressDerivationMode { hdWallet, importedKey }

class SetupBitcoinAddressView extends StatefulWidget {
  const SetupBitcoinAddressView({super.key});

  @override
  State<SetupBitcoinAddressView> createState() =>
      _SetupBitcoinAddressViewState();
}

class _SetupBitcoinAddressViewState extends State<SetupBitcoinAddressView>
    with SafeState {
  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupBitcoinAddressView");
  late final NetworkAccountCore networkAccounts;
  String? _error;
  final GlobalKey visibleContinue =
      GlobalKey(debugLabel: "visibleGenerateAddress");
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");

  AddressDerivationMode? selectedDerivationMode;
  bool showCustomKes = false;
  bool showSetupPage = false;
  bool inAddressPage = false;

  EncryptedCustomKey? selectedCustomKey;

  void onChangeCustomKey(EncryptedCustomKey? newSelected) {
    selectedCustomKey = newSelected;
    if (selectedCustomKey != null && showCustomKes) {
      showSetupPage = true;
    } else {
      showSetupPage = false;
    }
    setState(() {});
  }

  void goToAddressPage() {
    if (showSetupPage) {
      inAddressPage = true;
      setState(() {});
      ensureKeyVisible(key: visibleGenerateAddress);
    }
  }

  Future<bool> _onBackButton() async {
    if (pageProgressKey.isSuccess) return true;
    if (inAddressPage) {
      inAddressPage = false;
      p2shType = BitcoinAddressType.p2wpkhInP2sh;
      customKeyIndex = null;
      setState(() {});
      return false;
    }
    return true;
  }

  late final Map<AddressDerivationMode, Widget> derivationModes = {
    AddressDerivationMode.hdWallet: Text("hd_wallet".tr),
    AddressDerivationMode.importedKey: Text("imported_key".tr)
  };

  void onChangeDerivationMode<T>(T? mode) async {
    if (mode == selectedDerivationMode) return;
    selectedDerivationMode =
        (mode as AddressDerivationMode?) ?? selectedDerivationMode;
    _error = null;
    showCustomKes = false;
    showSetupPage = false;
    selectedCustomKey = null;

    try {
      if (selectedDerivationMode == AddressDerivationMode.importedKey) {
        if (customKeys.isEmpty) {
          _error = "empty_custom_key_desc".tr;
        } else {
          showCustomKes = true;
          selectedCustomKey = customKeys.first;
          showSetupPage = true;
        }
      } else {
        showSetupPage = true;
      }
      setState(() {});
    } finally {
      if (showSetupPage) {
        ensureKeyVisible(key: visibleContinue);
      }
    }
  }

  List<EncryptedCustomKey> customKeys = [];
  AppBitcoinNetwork get network => networkAccounts.network as AppBitcoinNetwork;
  List<CryptoCoins> get coins => network.coins;
  bool inited = false;
  Bip32AddressIndex? customKeyIndex;
  late final List<BitcoinAddressType> p2shTypes = [
    BitcoinAddressType.p2wshInP2sh,
    BitcoinAddressType.p2wpkhInP2sh,
    BitcoinAddressType.p2pkhInP2sh,
    BitcoinAddressType.p2pkInP2sh
  ];

  CryptoCoins findCoin() {
    return network.findCOinFromBitcoinAddressType(selected.first);
  }

  void _setupIAccount() {
    if (inited) return;
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    inited = true;
    networkAccounts = model.networkAccount;
    customKeys = model.getNetworkImportedKeys();
  }

  late Set<BitcoinAddressType> selected = {BitcoinAddressType.p2tr};
  void onChangeSelected<T>(Set<T> value) {
    selected = value.cast();
    p2shType = BitcoinAddressType.p2wpkhInP2sh;
    customKeyIndex = null;
    setState(() {});
  }

  bool get derivationStandard => customKeyIndex == null;
  BitcoinAddressType p2shType = BitcoinAddressType.p2wpkhInP2sh;
  void onChangeDerivation(bool? val, DynamicVoid onFalse) {
    if (val == null) return;
    if (derivationStandard) {
      onFalse();
      return;
    } else {
      customKeyIndex = null;
      setState(() {});
    }
  }

  void onChageSegwit(BitcoinAddressType? val) {
    if (!p2shTypes.contains(val)) return;
    p2shType = val ?? p2shType;
    setState(() {});
  }

  void setupKeyIndex(Bip32AddressIndex? newKeyIndex) {
    customKeyIndex = newKeyIndex;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    _setupIAccount();
    super.didChangeDependencies();
  }

  AddressDerivationIndex? derivationkey() {
    if (selectedCustomKey != null) {
      return ImportedAddressIndex(
          accountId: selectedCustomKey!.id, bip32KeyIndex: customKeyIndex);
    }
    return customKeyIndex;
  }

  void generateAddress() async {
    pageProgressKey.progressText("generating_new_addr".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    final coin = findCoin();

    final selectedType = selected.first == BitcoinAddressType.p2wpkhInP2sh
        ? p2shType
        : selected.first;
    final keyIndex = derivationkey() ?? model.networkAccount.nextDrive(coin);
    final newAccount = BitcoinNewAddressParams(
        coin: coin, deriveIndex: keyIndex, bitcoinAddressType: selectedType);

    final result = await model.deriveNewAccount(newAccount);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtomView(
            buttomText: "generate_new_address".tr,
            onPressed: () {
              if (mounted) {
                pageProgressKey.backToIdle();
              }
            },
            text: "address_added_success".tr,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: Text("setup_address".tr),
        ),
        body: PageProgress(
          key: pageProgressKey,
          backToIdle: AppGlobalConst.oneSecoundDuration,
          initialStatus: PageProgressStatus.idle,
          child: () => UnfocusableChild(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                  padding: WidgetConstant.paddingHorizontal20,
                  child: AnimatedSwitcher(
                    duration: AppGlobalConst.animationDuraion,
                    child: inAddressPage
                        ? Column(
                            key: const ValueKey<bool>(true),
                            children: [
                              _DriveFromHdWallet(
                                onVisibleGenerateAddress:
                                    visibleGenerateAddress,
                                onChangeDeravation: (p0) {
                                  onChangeDerivation(
                                    p0,
                                    () {
                                      context
                                          .openSliverBottomSheet<
                                                  Bip32AddressIndex>(
                                              _AddressTypePathSetup(
                                                  coin: findCoin()),
                                              "key_derivation".tr)
                                          .then(setupKeyIndex);
                                    },
                                  );
                                },
                                derivationStandard: derivationStandard,
                                generateAddress: generateAddress,
                                nestedP2shTyes: p2shTypes,
                                onChageSegwit: onChageSegwit,
                                onChangeSelected: onChangeSelected,
                                selected: selected,
                                selectedP2shType: p2shType,
                                customKey: selectedCustomKey,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              WidgetConstant.height20,
                              PageTitleSubtitle(
                                  title: "derive_bitcoin_address".tr,
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("bip44_desc".tr),
                                      WidgetConstant.height8,
                                      Text("bip49_desc".tr),
                                      WidgetConstant.height8,
                                      Text("bip84_desc".tr),
                                      WidgetConstant.height8,
                                      Text("bip86_desc".tr)
                                    ],
                                  )),
                              PageTitleSubtitle(
                                  title: "select_derivation_type".tr,
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("select_derivation_desc".tr)
                                    ],
                                  )),
                              AppDropDownBottom<AddressDerivationMode>(
                                items: derivationModes,
                                onChanged: onChangeDerivationMode,
                                label: "derivation_type".tr,
                                value: selectedDerivationMode,
                                error: _error,
                              ),
                              WidgetConstant.height20,
                              AnimatedSize(
                                duration: AppGlobalConst.animationDuraion,
                                child: showCustomKes
                                    ? _SelectCustomKeys(
                                        existsKeys: customKeys,
                                        selectedKey: selectedCustomKey,
                                        onChangeCustomKey: onChangeCustomKey,
                                      )
                                    : const SizedBox(),
                              ),
                              AnimatedSwitcher(
                                duration: AppGlobalConst.animationDuraion,
                                child: showSetupPage
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            FixedElevatedButton(
                                              padding: WidgetConstant
                                                  .paddingVertical20,
                                              onPressed: goToAddressPage,
                                              key: visibleContinue,
                                              child: Text("continue".tr),
                                            )
                                          ])
                                    : const SizedBox(),
                              )
                            ],
                          ),
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef _OnChangeCustomKey = void Function(EncryptedCustomKey?);

class _SelectCustomKeys extends StatelessWidget {
  const _SelectCustomKeys(
      {required this.existsKeys,
      required this.selectedKey,
      required this.onChangeCustomKey});
  final List<EncryptedCustomKey> existsKeys;
  final EncryptedCustomKey? selectedKey;
  final _OnChangeCustomKey onChangeCustomKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "choose_public_key".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("generate_from_imported_keys".tr),
                WidgetConstant.height8,
                Text("select_imported_key_desc".tr),
                WidgetConstant.height8,
              ],
            )),
        Column(
          children: List.generate(existsKeys.length, (index) {
            return RadioListTile(
              value: existsKeys[index],
              groupValue: selectedKey,
              onChanged: onChangeCustomKey,
              title: OneLineTextWidget(existsKeys[index].publicKey),
              subtitle: Text("imported_at"
                  .tr
                  .replaceOne(existsKeys[index].created.toString())),
            );
          }),
        ),
      ],
    );
  }
}

class _DriveFromHdWallet extends StatelessWidget {
  const _DriveFromHdWallet(
      {required this.selected,
      required this.onChangeDeravation,
      required this.generateAddress,
      required this.derivationStandard,
      required this.nestedP2shTyes,
      required this.onChageSegwit,
      required this.onChangeSelected,
      required this.selectedP2shType,
      required this.onVisibleGenerateAddress,
      this.customKey});
  final Set<BitcoinAddressType> selected;
  final void Function(BitcoinAddressType?) onChageSegwit;
  final DynamicVoid generateAddress;
  final VoidSetT onChangeSelected;
  final bool derivationStandard;
  final List<BitcoinAddressType> nestedP2shTyes;
  final BitcoinAddressType selectedP2shType;
  final NullBoolVoid onChangeDeravation;
  final EncryptedCustomKey? customKey;
  final GlobalKey onVisibleGenerateAddress;
  static String _getBipName(BitcoinAddressType select) {
    switch (select) {
      case BitcoinAddressType.p2pkh:
        return "BIP44";
      case BitcoinAddressType.p2wpkhInP2sh:
        return "BIP49";
      case BitcoinAddressType.p2wpkh:
      case BitcoinAddressType.p2wsh:
        return "BIP84";
      default:
        return "BIP86";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "choose_bitcoin_address_type".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("choose_bitcoin_address_type_desc".tr),
                WidgetConstant.height8,
                Text("bitcoin_type_recomended".tr),
                WidgetConstant.height8,
                if (customKey != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("generate_from_imported_keys".tr),
                      WidgetConstant.height8,
                      Text("generate_from_imported_key_desc1".tr)
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("generate_from_hd_wallet".tr),
                    ],
                  )
              ],
            )),
        AppSwitchListTile(
          value: derivationStandard,
          onChanged: onChangeDeravation,
          title: customKey == null
              ? Text("standard_derivation".tr)
              : Text("non_derivation".tr),
          subtitle: customKey == null
              ? Text("standard_deravation_for"
                  .tr
                  .replaceOne(_getBipName(selected.first)))
              : Text("import_key_derivation_desc2".tr),
        ),
        WidgetConstant.height8,
        AppSegmentedButton<BitcoinAddressType>(items: {
          BitcoinAddressType.p2pkh: BitcoinAddressType.p2pkh.value,
          BitcoinAddressType.p2wpkhInP2sh: "P2SH",
          BitcoinAddressType.p2wpkh: BitcoinAddressType.p2wpkh.value,
          BitcoinAddressType.p2wsh: BitcoinAddressType.p2wsh.value,
          BitcoinAddressType.p2tr: BitcoinAddressType.p2tr.value,
        }, onChangeSelected: onChangeSelected, selected: selected),
        WidgetConstant.height20,
        _AddressTypeOPtion(
          select: selected.first,
          deriveStandard: derivationStandard,
          nestedP2shTyes: nestedP2shTyes,
          selectedP2shType: selectedP2shType,
          onChangeP2shSegwit: onChageSegwit,
        ),
        FixedElevatedButton(
          padding: WidgetConstant.paddingVertical20,
          onPressed: generateAddress,
          key: onVisibleGenerateAddress,
          child: Text("generate_address".tr),
        )
      ],
    );
  }
}

typedef _OnChangeP2shType = void Function(BitcoinAddressType?);

class _AddressTypeOPtion extends StatelessWidget {
  const _AddressTypeOPtion({
    required this.select,
    required this.deriveStandard,
    required this.selectedP2shType,
    required this.onChangeP2shSegwit,
    required this.nestedP2shTyes,
  });
  final List<BitcoinAddressType> nestedP2shTyes;
  final BitcoinAddressType select;
  final bool deriveStandard;
  final BitcoinAddressType selectedP2shType;
  final _OnChangeP2shType onChangeP2shSegwit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppGlobalConst.animationDuraion,
      child: Column(
        key: ValueKey<BitcoinAddressType>(select),
        children: [
          if (select == BitcoinAddressType.p2wpkhInP2sh)
            Column(
              children: List.generate(
                  nestedP2shTyes.length,
                  (index) => AppRadioListTile(
                      title: Text(nestedP2shTyes[index].value),
                      value: nestedP2shTyes[index],
                      groupValue: selectedP2shType,
                      subtitle: Text(nestedP2shTyes[index].name.tr),
                      onChanged: onChangeP2shSegwit)),
            ),
          if (select == BitcoinAddressType.p2wsh)
            Text(
              "p2wsh_one_of_one_desc".tr,
              textAlign: TextAlign.center,
            )
        ],
      ),
    );
  }
}

class _AddressTypePathSetup extends StatefulWidget {
  const _AddressTypePathSetup({required this.coin});
  final CryptoCoins coin;

  @override
  State<_AddressTypePathSetup> createState() => _AddressTypePathSetupState();
}

class _AddressTypePathSetupState extends State<_AddressTypePathSetup> {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_AddressTypePathSetupState");
  final Map<Bip44Levels, GlobalKey<NumberTextFieldState>> levelStateKeys = {
    Bip44Levels.purpose: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_1"),
    Bip44Levels.coin: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_2"),
    Bip44Levels.account: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_3"),
    Bip44Levels.change: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_4"),
    Bip44Levels.addressIndex: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_5"),
  };

  String? validate(String? v, Bip44Levels level) {
    if (levels[level] == null) {
      return "bip32_key_index_validate".tr;
    }
    return null;
  }

  final Map<Bip44Levels, Bip44LevelsDetails?> levels = {
    Bip44Levels.purpose: null,
    Bip44Levels.coin: null,
    Bip44Levels.account: null,
    Bip44Levels.change: null,
    Bip44Levels.addressIndex: null,
  };
  void onChangedValue(String? v, Bip44Levels level) {
    if (v == null) return;
    try {
      levels[level] = Bip44LevelsDetails.fromIntIndex(int.parse(v), level);
    } on Exception {
      levels[level] = null;
    } finally {
      path = calculatePath();
      setState(() {});
    }
  }

  String? helperText(Bip44Levels level) {
    if (levels[level]?.isHardened ?? false) {
      return "hardened_index"
          .tr
          .replaceOne(levels[level]!.unHardendValue.toString());
    }
    return null;
  }

  Color? hardenedColor(Bip44Levels level) {
    return (levels[level]?.isHardened ?? false)
        ? context.theme.iconTheme.color
        : null;
  }

  void onSubmit() {
    if (!(form.currentState?.validate() ?? false)) return;
    final keyIndex = Bip32AddressIndex.fromBip44KeyIndexDetais(
        levels.values.toList().cast());
    context.pop(keyIndex);
  }

  void onTapHardened(Bip44Levels level) {
    if (levels[level]?.isHardened ?? true) return;
    stateKey(level)
        .currentState
        ?.changeIndex(Bip32KeyIndex.hardenIndex(levels[level]!.index).index);
  }

  GlobalKey<NumberTextFieldState> stateKey(Bip44Levels level) {
    return levelStateKeys[level]!;
  }

  String path = "";

  String calculatePath() {
    String p = "m";
    for (final i in levels.values) {
      if (i == null) {
        p += "/***";
      } else {
        p += "/${i.path}";
      }
    }
    return p;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "bip32_key_derivation".tr,
              subtitle: "p_note".tr,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("bip32_derivation_desc".tr),
                  WidgetConstant.height8,
                  Text("bip32_derivation_desc2".tr),
                  WidgetConstant.height8,
                  Text("bip32_derivation_desc3".tr)
                ],
              )),
          PageTitleSubtitle(
              title: "choose_index_each_level".tr,
              body: Text("bip32_level_desc".tr)),
          PageTitleSubtitle(
              title: "path".tr,
              body: AnimatedSwitcher(
                duration: AppGlobalConst.animationDuraion,
                child: Container(
                  key: ValueKey<String>(path),
                  padding: WidgetConstant.padding10,
                  decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: WidgetConstant.border8),
                  child: Text(
                    path,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              )),
          WidgetConstant.height20,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: NumberTextField(
                  label: "p_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  defaultValue:
                      (widget.coin.proposal as BipProposal).purpose.index,
                  helperText: helperText(Bip44Levels.purpose),
                  key: stateKey(Bip44Levels.purpose),
                  min: 0,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.purpose);
                  },
                  validator: (v) => validate(v, Bip44Levels.purpose),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.purpose);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.purpose),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "c_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.coin),
                  key: stateKey(Bip44Levels.coin),
                  defaultValue:
                      Bip32KeyIndex.hardenIndex(widget.coin.conf.coinIdx).index,
                  min: 0,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.coin);
                  },
                  validator: (v) => validate(v, Bip44Levels.coin),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.coin);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.coin),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "a_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.account),
                  key: stateKey(Bip44Levels.account),
                  min: 0,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.account);
                  },
                  validator: (v) => validate(v, Bip44Levels.account),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.account);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.account),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "change_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.change),
                  key: stateKey(Bip44Levels.change),
                  min: 0,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.change);
                  },
                  validator: (v) => validate(v, Bip44Levels.change),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.change);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.change),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "address_index".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.addressIndex),
                  key: stateKey(Bip44Levels.addressIndex),
                  min: 0,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.addressIndex);
                  },
                  validator: (v) => validate(v, Bip44Levels.addressIndex),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.addressIndex);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.addressIndex),
                        )),
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: onSubmit,
                child: Text("setup_derivation_path".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}
