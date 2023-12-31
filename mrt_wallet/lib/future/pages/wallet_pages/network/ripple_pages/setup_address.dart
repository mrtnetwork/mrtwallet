import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation_type.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/bip32_derivation.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

class SetupRippleAddressView extends StatefulWidget {
  const SetupRippleAddressView({super.key});

  @override
  State<SetupRippleAddressView> createState() => _SetupRippleAddressViewState();
}

class _SetupRippleAddressViewState extends State<SetupRippleAddressView>
    with SafeState {
  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupBitcoinAddressView");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  late final NetworkAccountCore networkAccounts;
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

  String? validateTag(String? v) {
    if (!isXAddress) return null;
    final newTag = int.tryParse(v ?? "");
    if (newTag == null || newTag < 0 || newTag > mask32 - 1) {
      return "tag_validator".tr;
    }
    return null;
  }

  bool inAddressPage = false;
  Set<XrpAddressType> addressTyoe = {XrpAddressType.classic};
  void onSelectAddressType(Set<XrpAddressType> selectType) {
    addressTyoe = selectType;
    setState(() {});
    if (isXAddress) {
      ensureKeyVisible(key: visibleXAddressDetails);
    }
  }

  bool get isXAddress => addressTyoe.first == XrpAddressType.xAddress;

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

  AppXRPNetwork get network => networkAccounts.network as AppXRPNetwork;
  List<CryptoCoins> get coins => network.coins;
  bool inited = false;
  Bip32AddressIndex? customKeyIndex;

  void _setupIAccount() {
    if (inited) return;
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    networkAccounts = model.networkAccount;
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

  void generateAddress() async {
    if (!(form.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    final curve = selectedCustomKey?.type ?? EllipticCurveTypes.secp256k1;
    final coin = coins.firstWhere((element) => element.conf.type == curve);

    final keyIndex = derivationkey() ?? model.networkAccount.nextDrive(coin);
    final newAccount = RippleNewAddressParam(
        coin: coin,
        deriveIndex: keyIndex,
        type: curve,
        tag: addressTyoe.first == XrpAddressType.classic ? null : tag);

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
            child: CustomScrollView(
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
                                        Text("choose_bitcoin_address_type_desc"
                                            .tr),
                                        Text("x_address_desc".tr),
                                        WidgetConstant.height8,
                                        Text("classic_address_desc".tr),
                                        WidgetConstant.height8,
                                        if (selectedCustomKey != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("generate_from_imported_keys"
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
                                              Text(
                                                  "generate_from_hd_wallet".tr),
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
                                                  coin: coins.first,
                                                  curve: EllipticCurveTypes
                                                      .ed25519,
                                                ))
                                            .then(setupKeyIndex);
                                      },
                                    );
                                  },
                                  title: customKeyIndex == null
                                      ? Text("standard_derivation".tr)
                                      : Text("non_derivation".tr),
                                  subtitle: customKeyIndex == null
                                      ? Text("standard_deravation_for"
                                          .tr
                                          .replaceOne(coins
                                              .first.proposal.specName
                                              .toUpperCase()))
                                      : Text("import_key_derivation_desc2".tr),
                                ),
                                WidgetConstant.height20,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: AppSegmentedButton<XrpAddressType>(
                                        items: {
                                          XrpAddressType.classic:
                                              XrpAddressType.classic.value.tr,
                                          XrpAddressType.xAddress:
                                              XrpAddressType.xAddress.value.tr
                                        },
                                        selected: addressTyoe,
                                        onChangeSelected: onSelectAddressType,
                                      ),
                                    ),
                                  ],
                                ),
                                WidgetConstant.height20,
                                AnimatedSize(
                                    duration: AppGlobalConst.animationDuraion,
                                    child: isXAddress
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              PageTitleSubtitle(
                                                  title: "x_address_desc2".tr,
                                                  body: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("x_address_desc3".tr)
                                                    ],
                                                  )),
                                              PageTitleSubtitle(
                                                  key: visibleXAddressDetails,
                                                  title: "assigning_tag".tr,
                                                  body: Text(
                                                      "enter_tag_desc".tr)),
                                              WidgetConstant.height20,
                                              NumberTextField(
                                                  label: "tag".tr,
                                                  onChange: onChangeTag,
                                                  validator: validateTag,
                                                  defaultValue: tag,
                                                  max: mask32 - 1,
                                                  min: 0),
                                            ],
                                          )
                                        : const SizedBox()),
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
                          )
                        : Column(
                            children: [
                              WidgetConstant.height20,
                              PageTitleSubtitle(
                                  title: "derive_network_address"
                                      .tr
                                      .replaceOne(network.coinParam.token.name),
                                  subtitle: "bip44_derivation".tr,
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("bip44_derivation_desc".tr),
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
    );
  }
}
