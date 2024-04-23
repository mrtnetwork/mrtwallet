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

class SetupEthereumAddressView extends StatefulWidget {
  const SetupEthereumAddressView({super.key});

  @override
  State<SetupEthereumAddressView> createState() =>
      _SetupEthereumAddressViewState();
}

class _SetupEthereumAddressViewState extends State<SetupEthereumAddressView>
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
  AddressDerivationMode? selectedDerivationMode;
  EncryptedCustomKey? selectedCustomKey;
  int tag = 0;

  void onChangeTag(String v) {
    final newTag = int.tryParse(v);
    if (newTag == null || newTag < 0 || newTag > mask32 - 1) return;
    tag = newTag;
  }

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

      customKeyIndex = null;
    }
    setState(() {});
  }

  APPEVMNetwork get network => networkAccounts.network as APPEVMNetwork;
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

  AddressDerivationIndex? derivationkey(CryptoCoins coin) {
    if (selectedCustomKey != null) {
      return ImportedAddressIndex(
          accountId: selectedCustomKey!.id,
          bip32KeyIndex: customKeyIndex,
          currencyCoin: coin);
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
    final curve = selectedCustomKey?.type ?? EllipticCurveTypes.secp256k1;
    final coin = coins.firstWhere((element) => element.conf.type == curve);

    final keyIndex =
        derivationkey(coin) ?? chainAccount.account.nextDrive(coin);
    final newAccount =
        EthereumNewAddressParam(coin: coin, deriveIndex: keyIndex);

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
                          ? Form(
                              key: form,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                key: const ValueKey<bool>(true),
                                children: [
                                  PageTitleSubtitle(
                                      title: "derive_network_address"
                                          .tr
                                          .replaceOne(
                                              network.coinParam.token.name),
                                      body: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "disable_standard_derivation".tr),
                                          WidgetConstant.height8,
                                          if (selectedCustomKey != null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "generate_from_imported_keys"
                                                        .tr),
                                                WidgetConstant.height8,
                                                Text(
                                                    "generate_from_imported_key_desc1"
                                                        .tr)
                                              ],
                                            )
                                          else
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("generate_from_hd_wallet"
                                                    .tr),
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
                                              .openSliverBottomSheet<
                                                      Bip32AddressIndex>(
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
                                        ? Text(customKeyIndex?.path ??
                                            standardDerivation.path)
                                        : Text(customKeyIndex?.path ??
                                            "import_key_derivation_desc2".tr),
                                  ),
                                  WidgetConstant.height20,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FixedElevatedButton(
                                        padding:
                                            WidgetConstant.paddingVertical20,
                                        onPressed: generateAddress,
                                        child: Text("generate_address".tr),
                                      ),
                                    ],
                                  )
                                ],
                              ),
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
