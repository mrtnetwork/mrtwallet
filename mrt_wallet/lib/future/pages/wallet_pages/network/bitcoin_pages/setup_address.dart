import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/types/typedef.dart';

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
  late final AppChain chainAccount;
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");
  AddressDerivationMode? selectedDerivationMode;
  EncryptedCustomKey? selectedCustomKey;

  bool inAddressPage = false;

  void goToAddressPage(
      AddressDerivationMode derivationMode, EncryptedCustomKey? customKey) {
    if (derivationMode == AddressDerivationMode.importedKey &&
        customKey == null) return;
    selectedDerivationMode = derivationMode;
    selectedCustomKey = customKey;
    inAddressPage = true;
    setState(() {});
    ensureKeyVisible(key: visibleGenerateAddress);
  }

  void _onBackButton() {
    if (pageProgressKey.isSuccess) return;
    if (inAddressPage) {
      selectedDerivationMode = null;
      selectedCustomKey = null;
      inAddressPage = false;
      p2shType = _defaultP2sh();
      customKeyIndex = null;
    }
    setState(() {});
  }

  AppBitcoinNetwork get network => chainAccount.network as AppBitcoinNetwork;
  List<CryptoCoins> get coins => network.coins;
  bool inited = false;
  Bip32AddressIndex? customKeyIndex;
  late final List<BitcoinAddressType> p2shTypes;
  late final List<BitcoinAddressType> supportAddressTypes;
  late final Map<BitcoinAddressType, String> typesToSelect = {
    BitcoinAddressType.p2pkh: BitcoinAddressType.p2pkh.value,
    if (p2shTypes.contains(BitcoinAddressType.p2wpkhInP2sh))
      BitcoinAddressType.p2wpkhInP2sh: "P2SH"
    else
      BitcoinAddressType.p2pkhInP2sh: "P2SH",
    if (supportAddressTypes.contains(BitcoinAddressType.p2wpkh))
      BitcoinAddressType.p2wpkh: BitcoinAddressType.p2wpkh.value,
    if (supportAddressTypes.contains(BitcoinAddressType.p2wsh))
      BitcoinAddressType.p2wsh: BitcoinAddressType.p2wsh.value,
    if (supportAddressTypes.contains(BitcoinAddressType.p2tr))
      BitcoinAddressType.p2tr: BitcoinAddressType.p2tr.value,
  };

  late final bool isSupportSegwit;
  late final bool isSupportP2tr;

  CryptoCoins findCoin() {
    return network.findCOinFromBitcoinAddressType(selected.first);
  }

  void _setupIAccount() {
    if (inited) return;
    inited = true;
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    chainAccount = model.chain;
    supportAddressTypes =
        network.coinParam.transacationNetwork.supportedAddress;
    p2shTypes = supportAddressTypes.where((e) => e.isP2sh).toList();
    p2shType = _defaultP2sh();
    isSupportP2tr = supportAddressTypes.contains(BitcoinAddressType.p2tr);
    isSupportSegwit = supportAddressTypes.contains(BitcoinAddressType.p2wpkh);
    if (isSupportP2tr) {
      selected = {BitcoinAddressType.p2tr};
    } else if (isSupportSegwit) {
      selected = {BitcoinAddressType.p2wpkh};
    } else {
      selected = {BitcoinAddressType.p2pkh};
    }
  }

  late Set<BitcoinAddressType> selected;

  BitcoinAddressType _defaultP2sh() {
    if (p2shTypes.contains(BitcoinAddressType.p2wpkhInP2sh)) {
      return BitcoinAddressType.p2wpkhInP2sh;
    }
    return BitcoinAddressType.p2pkInP2sh;
  }

  void onChangeSelected(Set<BitcoinAddressType> value) {
    selected = value;
    p2shType = _defaultP2sh();
    customKeyIndex = null;
    setState(() {});
  }

  bool get derivationStandard => customKeyIndex == null;
  late BitcoinAddressType p2shType;
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

  AddressDerivationIndex get standardDerivation {
    final coin = findCoin();
    return chainAccount.account.nextDrive(coin);
  }

  void generateAddress() async {
    pageProgressKey.progressText("generating_new_addr".tr);
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final coin = findCoin();

    final selectedType =
        selected.first == _defaultP2sh() ? p2shType : selected.first;
    final keyIndex = derivationkey() ?? chainAccount.account.nextDrive(coin);
    final newAccount = BitcoinNewAddressParams(
        coin: coin, deriveIndex: keyIndex, bitcoinAddressType: selectedType);

    final result = await wallet.deriveNewAccount(newAccount);
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !inAddressPage || pageProgressKey.isSuccess,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onBackButton();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("setup_address".tr),
        ),
        body: PageProgress(
          key: pageProgressKey,
          backToIdle: AppGlobalConst.oneSecoundDuration,
          initialStatus: PageProgressStatus.idle,
          child: () => UnfocusableChild(
            child: Center(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    child: AnimatedSwitcher(
                      duration: AppGlobalConst.animationDuraion,
                      child: inAddressPage
                          ? Column(
                              key: const ValueKey<bool>(true),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DriveFromHdWallet(
                                  customKeyIndex: customKeyIndex,
                                  onVisibleGenerateAddress:
                                      visibleGenerateAddress,
                                  nextStandartIndex: standardDerivation,
                                  onChangeDeravation: (p0) {
                                    onChangeDerivation(
                                      p0,
                                      () {
                                        context
                                            .openSliverBottomSheet<
                                                    Bip32AddressIndex>(
                                                "key_derivation".tr,
                                                child: Bip32KeyDerivationView(
                                                    coin: findCoin(),
                                                    curve: EllipticCurveTypes
                                                        .secp256k1))
                                            .then(setupKeyIndex);
                                      },
                                    );
                                  },
                                  derivationStandard: derivationStandard,
                                  typesToSelect: typesToSelect,
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
                                  title: "derive_network_address"
                                      .tr
                                      .replaceOne(network.coinParam.token.name),
                                  body: LargeTextView([
                                    "bip44_desc".tr,
                                    "bip49_desc".tr,
                                    if (isSupportSegwit) "bip84_desc".tr,
                                    if (isSupportP2tr) "bip86_desc".tr
                                  ]),
                                ),
                                SetupAddressDerivation(goToAddressPage)
                              ],
                            ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriveFromHdWallet extends StatelessWidget {
  const _DriveFromHdWallet(
      {required this.selected,
      required this.customKeyIndex,
      required this.onChangeDeravation,
      required this.generateAddress,
      required this.derivationStandard,
      required this.nestedP2shTyes,
      required this.onChageSegwit,
      required this.onChangeSelected,
      required this.selectedP2shType,
      required this.onVisibleGenerateAddress,
      required this.typesToSelect,
      required this.nextStandartIndex,
      this.customKey});
  final AddressDerivationIndex nextStandartIndex;
  final AddressDerivationIndex? customKeyIndex;
  final Set<BitcoinAddressType> selected;
  final void Function(BitcoinAddressType?) onChageSegwit;
  final DynamicVoid generateAddress;
  final VoidSetT<BitcoinAddressType> onChangeSelected;
  final bool derivationStandard;
  final List<BitcoinAddressType> nestedP2shTyes;
  final BitcoinAddressType selectedP2shType;
  final NullBoolVoid onChangeDeravation;
  final EncryptedCustomKey? customKey;
  final GlobalKey onVisibleGenerateAddress;
  final Map<BitcoinAddressType, String> typesToSelect;

  bool get supportP2trOrSegwit =>
      typesToSelect.containsKey(BitcoinAddressType.p2tr) ||
      typesToSelect.containsKey(BitcoinAddressType.p2wpkh);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "choose_bitcoin_address_type".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("choose_bitcoin_address_type_desc".tr),
                WidgetConstant.height8,
                if (supportP2trOrSegwit) Text("bitcoin_type_recomended".tr),
                WidgetConstant.height8,
                if (customKey != null) ...[
                  Text("generate_from_imported_keys".tr),
                  WidgetConstant.height8,
                  Text("generate_from_imported_key_desc1".tr)
                ] else ...[
                  Text("generate_from_hd_wallet".tr),
                ]
              ],
            )),
        AppSwitchListTile(
          value: derivationStandard,
          onChanged: onChangeDeravation,
          title: customKey == null
              ? Text(derivationStandard
                  ? "standard_derivation".tr
                  : "custom_derivation".tr)
              : Text(customKeyIndex == null
                  ? "non_derivation".tr
                  : "custom_derivation".tr),
          subtitle: customKey == null
              ? Text(customKeyIndex?.path ?? nextStandartIndex.path)
              : Text(customKeyIndex?.path ?? "import_key_derivation_desc2".tr),
        ),
        WidgetConstant.height8,
        SizedBox(
          width: context.mediaQuery.size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSegmentedButton<BitcoinAddressType>(
                  items: typesToSelect,
                  onChangeSelected: onChangeSelected,
                  selected: selected),
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
          ),
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
          if (select.isP2sh)
            Column(
              children: List.generate(nestedP2shTyes.length, (index) {
                return AppRadioListTile(
                    title: Text(nestedP2shTyes[index].value),
                    value: nestedP2shTyes[index],
                    groupValue: selectedP2shType,
                    subtitle: Text(nestedP2shTyes[index].value.tr),
                    onChanged: onChangeP2shSegwit);
              }),
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
