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

typedef _OnChangeDerivation = void Function(bool? val, DynamicVoid onFalse);
typedef _OnSetupKeyIndex = void Function(Bip32AddressIndex? newKeyIndex);

class SetupCosmosAddressView extends StatefulWidget {
  const SetupCosmosAddressView({super.key});

  @override
  State<SetupCosmosAddressView> createState() => _SetupCosmosAddressViewState();
}

class _SetupCosmosAddressViewState extends State<SetupCosmosAddressView>
    with SafeState {
  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupEthereumAddressView");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  late final AppChain chainAccount;
  NetworkAccountCore get networkAccounts => chainAccount.account;
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");
  final GlobalKey visibleXAddressDetails =
      GlobalKey(debugLabel: "visibleContinue");

  // EllipticCurveTypes algorithm = EllipticCurveTypes.secp256k1;
  // void onChangeAlgorithm(EllipticCurveTypes algo) {
  //   algorithm = algo;
  //   setState(() {});
  // }

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
    try {
      if (inAddressPage) {
        selectedDerivationMode = null;
        selectedCustomKey = null;
        inAddressPage = false;
        customKeyIndex = null;
      }
    } finally {
      setState(() {});
    }
  }

  APPCosmosNetwork get network => networkAccounts.network as APPCosmosNetwork;
  List<CryptoCoins> get coins => network.coins;
  CryptoCoins get coin => coins.firstWhere((element) =>
      element.conf.type ==
      (selectedCustomKey?.type ?? EllipticCurveTypes.secp256k1));
  bool inited = false;
  Bip32AddressIndex? customKeyIndex;

  void _setupIAccount() {
    if (inited) return;
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    chainAccount = model.chain;
  }

  bool get derivationStandard => customKeyIndex == null;
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
    return chainAccount.account.nextDrive(coin);
  }

  void generateAddress() async {
    if (!(form.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);

    final keyIndex = derivationkey() ?? chainAccount.account.nextDrive(coin);
    final newAccount =
        CosmosNewAddressParams(coin: coin, deriveIndex: keyIndex);

    final result = await model.deriveNewAccount(newAccount);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtomView(
            buttomText: "generate_new_address".tr,
            buttomWidget: ContainerWithBorder(
                margin: WidgetConstant.paddingVertical8,
                child: AddressDetailsView(address: result.result)),
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
                          ? _GenerateAddress(
                              network: network,
                              form: form,
                              derivationStandard: derivationStandard,
                              onChangeDerivation: onChangeDerivation,
                              coin: coin,
                              setupKeyIndex: setupKeyIndex,
                              standardDerivation: standardDerivation,
                              generateAddress: generateAddress,
                              customKeyIndex: customKeyIndex,
                              selectedCustomKey: selectedCustomKey,
                            )
                          : Column(
                              children: [
                                WidgetConstant.height20,
                                PageTitleSubtitle(
                                    title: "derive_network_address"
                                        .tr
                                        .replaceOne(
                                            network.coinParam.token.name),
                                    body: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LargeTextView(
                                            ["bip44_derivation_desc".tr]),
                                      ],
                                    )),
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

class _GenerateAddress extends StatelessWidget {
  const _GenerateAddress(
      {required this.network,
      required this.form,
      this.selectedCustomKey,
      required this.derivationStandard,
      required this.onChangeDerivation,
      this.customKeyIndex,
      required this.coin,
      required this.setupKeyIndex,
      required this.standardDerivation,
      required this.generateAddress});
  final APPCosmosNetwork network;
  final GlobalKey<FormState> form;
  final EncryptedCustomKey? selectedCustomKey;
  final bool derivationStandard;
  final _OnChangeDerivation onChangeDerivation;
  final Bip32AddressIndex? customKeyIndex;
  final CryptoCoins coin;
  final _OnSetupKeyIndex setupKeyIndex;
  final AddressDerivationIndex standardDerivation;
  final DynamicVoid generateAddress;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        key: const ValueKey<bool>(true),
        children: [
          PageTitleSubtitle(
              title: "derive_network_address"
                  .tr
                  .replaceOne(network.coinParam.token.name),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("disable_standard_derivation".tr),
                  WidgetConstant.height8,
                  if (selectedCustomKey != null)
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
            onChanged: (p0) {
              onChangeDerivation(
                p0,
                () {
                  context
                      .openSliverBottomSheet<Bip32AddressIndex>(
                          "key_derivation".tr,
                          child: Bip32KeyDerivationView(
                            coin: coin,
                            curve: coin.conf.type,
                          ))
                      .then(setupKeyIndex);
                },
              );
            },
            title: selectedCustomKey == null
                ? Text(derivationStandard
                    ? "standard_derivation".tr
                    : "custom_derivation".tr)
                : Text(customKeyIndex == null
                    ? "non_derivation".tr
                    : "custom_derivation".tr),
            subtitle: selectedCustomKey == null
                ? Text(customKeyIndex?.path ?? standardDerivation.path)
                : Text(
                    customKeyIndex?.path ?? "import_key_derivation_desc2".tr),
          ),
          WidgetConstant.height20,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: generateAddress,
                child: Text("generate_address".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// class _ChooseAddressGenerationAlgorithm extends StatelessWidget {
//   const _ChooseAddressGenerationAlgorithm(
//       {required this.onChageAlgorithm,
//       required this.algo,
//       required this.onChange});
//   final _OnAddressAlgorithm onChageAlgorithm;
//   final EllipticCurveTypes algo;
//   final _OnChangePage onChange;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("elliptic_curve_options".tr, style: context.textTheme.titleMedium),
//         Text("address_generation_algorithm".tr),
//         WidgetConstant.height20,
//         AppRadioListTile(
//           title: const Text("Secp256k1"),
//           groupValue: algo,
//           value: EllipticCurveTypes.secp256k1,
//           onChanged: (value) => onChageAlgorithm(EllipticCurveTypes.secp256k1),
//         ),
//         AppRadioListTile(
//           title: const Text("Nist256p1"),
//           groupValue: algo,
//           value: EllipticCurveTypes.nist256p1,
//           onChanged: (value) => onChageAlgorithm(EllipticCurveTypes.nist256p1),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FixedElevatedButton(
//                 padding: WidgetConstant.paddingVertical20,
//                 child: Text("continue".tr),
//                 onPressed: () {
//                   onChange(_Page.generationAddress);
//                 }),
//           ],
//         )
//       ],
//     );
//   }
// }
