import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/byron_legacy_derivation.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

typedef _OnChangeDerivation = void Function(bool? val, DynamicVoid onFalse);
typedef _SetupKeyIndex = void Function(AddressDerivationIndex? newKeyIndex);
typedef _OnChangeShellyAddrType = void Function(ADAAddressType? addrType);

enum _AdaEra {
  shelly("shelly"),
  byron("byron");

  final String name;
  const _AdaEra(this.name);
  bool get isShelly => this == _AdaEra.shelly;
}

enum _CardanoMasterKeyGenerationType {
  ledger("ledger"),
  icarus("icarus"),
  byronLegacy("byronLegacy");

  final String name;
  const _CardanoMasterKeyGenerationType(this.name);
  bool get isLegacy => this == _CardanoMasterKeyGenerationType.byronLegacy;
}

enum _GenerateAddressPage {
  seedGeneration,
  era,
  masterKeyGeneration,
  generateAddress
}

/// add testnet coin
class SetupCardanoAddressView extends StatefulWidget {
  const SetupCardanoAddressView({super.key});

  @override
  State<SetupCardanoAddressView> createState() =>
      _SetupCardanoAddressViewState();
}

class _SetupCardanoAddressViewState extends State<SetupCardanoAddressView>
    with SafeState {
  final GlobalKey<PageProgressState> pageProgressKey =
      GlobalKey<PageProgressState>(debugLabel: "SetupEthereumAddressView");
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  late final AppChain chainAccount;
  AddressDerivationIndex get standardDerivation {
    return chainAccount.account.nextDrive(coin,
        masterKeyGeneration:
            keyGenerationType == _CardanoMasterKeyGenerationType.byronLegacy
                ? SeedGenerationType.byronLegacySeed
                : SeedGenerationType.bip39,
        seedGeneration: seedGenerationType);
  }

  NetworkAccountCore get networkAccounts => chainAccount.account;
  final GlobalKey visibleGenerateAddress =
      GlobalKey(debugLabel: "visibleContinue");
  final GlobalKey visibleXAddressDetails =
      GlobalKey(debugLabel: "visibleContinue");
  AddressDerivationMode? selectedDerivationMode;
  EncryptedCustomKey? selectedCustomKey;
  _AdaEra era = _AdaEra.shelly;
  _GenerateAddressPage page = _GenerateAddressPage.seedGeneration;
  bool byronLegacy = false;
  void changeByronLegacy(bool? change) {
    byronLegacy = !byronLegacy;
    setState(() {});
  }

  void onChangeEra(_AdaEra? e) {
    era = e ?? era;
    setState(() {});
  }

  void onContinueFromSeedGeneration() {
    page = _GenerateAddressPage.era;
    setState(() {});
  }

  void onContinueFromEra() {
    page = _GenerateAddressPage.masterKeyGeneration;
    if (era == _AdaEra.byron) {
      addrType = ADAAddressType.byron;
    } else {
      addrType = ADAAddressType.base;
      keyGenerationType = _CardanoMasterKeyGenerationType.icarus;
    }
    setState(() {});
  }

  _CardanoMasterKeyGenerationType keyGenerationType =
      _CardanoMasterKeyGenerationType.icarus;
  void onChangeMasterKeyGeneration(_CardanoMasterKeyGenerationType? e) {
    keyGenerationType = e ?? keyGenerationType;
    setState(() {});
  }

  SeedGenerationType seedGenerationType = SeedGenerationType.icarus;
  void onChangeSeedGeneration(SeedGenerationType? e) {
    if (e == SeedGenerationType.bip39) return;
    seedGenerationType = e ?? seedGenerationType;
    setState(() {});
  }

  void onContinueFromMasterkeyGeneration() {
    page = _GenerateAddressPage.generateAddress;
    switch (keyGenerationType) {
      case _CardanoMasterKeyGenerationType.icarus:
        if (era.isShelly) {
          if (network.coinParam.mainnet) {
            coin = Cip1852Coins.cardanoIcarus;
          } else {
            coin = Cip1852Coins.cardanoIcarusTestnet;
          }
        } else {
          if (network.coinParam.mainnet) {
            coin = Bip44Coins.cardanoByronIcarus;
          } else {
            coin = Bip44Coins.cardanoByronIcarusTestnet;
          }
        }
        break;
      default:
        if (era.isShelly) {
          if (network.coinParam.mainnet) {
            coin = Cip1852Coins.cardanoLedger;
          } else {
            coin = Cip1852Coins.cardanoLedgerTestnet;
          }
        } else {
          if (network.coinParam.mainnet) {
            coin = Bip44Coins.cardanoByronLedger;
          } else {
            coin = Bip44Coins.cardanoByronLedgerTestnet;
          }
        }
        break;
    }
    setState(() {});
  }

  ADAAddressType addrType = ADAAddressType.base;

  void onChangeShellyddrType(ADAAddressType? type) {
    if (type == null) return;
    if (era == _AdaEra.byron) return;
    if (type == ADAAddressType.pointer) return;
    addrType = type;
    setState(() {});
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
      page = _GenerateAddressPage.seedGeneration;
      keyGenerationType = _CardanoMasterKeyGenerationType.icarus;
      addrType = ADAAddressType.base;
      era = _AdaEra.shelly;
    }
    setState(() {});
  }

  APPCardanoNetwork get network => networkAccounts.network as APPCardanoNetwork;
  List<CryptoCoins> get coins => network.coins;
  late CryptoCoins coin = coins.firstWhere((element) =>
      element.conf.type ==
      (selectedCustomKey?.type ?? EllipticCurveTypes.ed25519Kholaw));
  bool inited = false;
  AddressDerivationIndex? customKeyIndex;

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

  void setupKeyIndex(AddressDerivationIndex? newKeyIndex) {
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

  void generateAddress() async {
    if (!(form.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("generating_new_addr".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    final keyIndex = derivationkey(coin) ??
        chainAccount.account.nextDrive(coin,
            seedGeneration: seedGenerationType,
            masterKeyGeneration:
                keyGenerationType == _CardanoMasterKeyGenerationType.byronLegacy
                    ? SeedGenerationType.byronLegacySeed
                    : SeedGenerationType.bip39);

    final newAccount = CardanoNewAddressParams(
        coin: coin,
        deriveIndex: keyIndex,
        addressType: addrType,
        byronLegacy: era.isShelly ? null : byronLegacy);

    final result = await model.deriveNewAccount(newAccount);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.success(
          backToIdle: false,
          progressWidget: SuccessWithButtomView(
            buttomWidget: ContainerWithBorder(
                margin: WidgetConstant.paddingVertical8,
                child: AddressDetailsView(address: result.result)),
            buttomText: "generate_new_address".tr,
            onPressed: () {
              if (mounted) {
                pageProgressKey.backToIdle();
              }
            },
          ));
    }
    setState(() {});
  }

  String? byronLegacyDerivationValidator(String? v, int index) {
    final int? parse = int.tryParse(v ?? "");
    if (parse == null) return "invalid_derivation_index".tr;
    if (parse.isNegative || parse > Bip32KeyDataConst.keyIndexMaxVal) {
      return "invalid_derivation_index".tr;
    }
    return null;
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
        appBar: AppBar(title: Text("setup_address".tr)),
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
                                  AnimatedSwitcher(
                                    duration: AppGlobalConst.animationDuraion,
                                    child: page ==
                                            _GenerateAddressPage.seedGeneration
                                        ? _SelectSeedGenerationType(
                                            seedGenerationType:
                                                seedGenerationType,
                                            onChageSeedGeneration:
                                                onChangeSeedGeneration,
                                            onContinue:
                                                onContinueFromSeedGeneration)
                                        : page == _GenerateAddressPage.era
                                            ? _SelectEra(
                                                era: era,
                                                onChangeEra: onChangeEra,
                                                onContinue: onContinueFromEra)
                                            : page ==
                                                    _GenerateAddressPage
                                                        .masterKeyGeneration
                                                ? _SelectMasterKeyGeneration(
                                                    keyGenerationType:
                                                        keyGenerationType,
                                                    era: era,
                                                    onChangeKeyGeneration:
                                                        onChangeMasterKeyGeneration,
                                                    onContinue:
                                                        onContinueFromMasterkeyGeneration,
                                                    seedGeneration:
                                                        seedGenerationType,
                                                  )
                                                : _GenerateAddress(
                                                    network: network,
                                                    addrType: addrType,
                                                    generateAddress:
                                                        generateAddress,
                                                    coin: coin,
                                                    derivationStandard:
                                                        derivationStandard,
                                                    era: era,
                                                    onChangeDerivation:
                                                        onChangeDerivation,
                                                    onChangeShellyddrType:
                                                        onChangeShellyddrType,
                                                    setupKeyIndex:
                                                        setupKeyIndex,
                                                    standardDerivation:
                                                        standardDerivation,
                                                    customKeyIndex:
                                                        customKeyIndex,
                                                    selectedCustomKey:
                                                        selectedCustomKey,
                                                    masterKeyGenerationType:
                                                        keyGenerationType),
                                  ),
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
                                  body: LargeTextView(
                                      ["bip44_derivation_desc".tr]),
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

typedef _OnChangeEra = void Function(_AdaEra? era);

class _SelectEra extends StatelessWidget {
  const _SelectEra(
      {required this.era, required this.onChangeEra, required this.onContinue});
  final _AdaEra era;
  final _OnChangeEra onChangeEra;
  final DynamicVoid onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "cardano_era".tr,
            body: Column(
              children: [
                Text("select_era_for_generate_addr".tr),
                WidgetConstant.height8,
                Text("recommended_address_type".tr)
              ],
            )),
        AppRadioListTile(
          groupValue: era,
          title: Text("shelly".tr),
          value: _AdaEra.shelly,
          onChanged: onChangeEra,
        ),
        AppRadioListTile(
          groupValue: era,
          value: _AdaEra.byron,
          title: Text("byron".tr),
          onChanged: onChangeEra,
        ),
        WidgetConstant.height20,
        ElevatedButton(onPressed: onContinue, child: Text("continue".tr))
      ],
    );
  }
}

typedef _OnChangeMasterKeyGeneration = void Function(
    _CardanoMasterKeyGenerationType? era);

class _SelectMasterKeyGeneration extends StatelessWidget {
  const _SelectMasterKeyGeneration(
      {required this.keyGenerationType,
      required this.onChangeKeyGeneration,
      required this.onContinue,
      required this.era,
      required this.seedGeneration});
  final _CardanoMasterKeyGenerationType keyGenerationType;
  final _OnChangeMasterKeyGeneration onChangeKeyGeneration;
  final DynamicVoid onContinue;
  final _AdaEra era;
  final SeedGenerationType seedGeneration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "master_key_generation".tr,
            body: Column(
              children: [
                Text("cardano_bip32_master_key".tr),
                WidgetConstant.height8,
                Text("choose_master_key_gen".tr)
              ],
            )),
        AppRadioListTile(
          groupValue: keyGenerationType,
          title: Text("ledger".tr),
          value: _CardanoMasterKeyGenerationType.ledger,
          onChanged: onChangeKeyGeneration,
        ),
        AppRadioListTile(
          groupValue: keyGenerationType,
          value: _CardanoMasterKeyGenerationType.icarus,
          title: Text("icarus".tr),
          onChanged: onChangeKeyGeneration,
        ),
        if (!era.isShelly &&
            seedGeneration == SeedGenerationType.byronLegacySeed)
          AppRadioListTile(
            groupValue: keyGenerationType,
            value: _CardanoMasterKeyGenerationType.byronLegacy,
            title: Text("byron_legacy".tr),
            onChanged: onChangeKeyGeneration,
          ),
        WidgetConstant.height20,
        ElevatedButton(onPressed: onContinue, child: Text("continue".tr))
      ],
    );
  }
}

typedef _OnChangeSeedGeneration = void Function(SeedGenerationType? era);

class _SelectSeedGenerationType extends StatelessWidget {
  const _SelectSeedGenerationType(
      {required this.seedGenerationType,
      required this.onChageSeedGeneration,
      required this.onContinue});
  final SeedGenerationType seedGenerationType;
  final _OnChangeSeedGeneration onChageSeedGeneration;
  final DynamicVoid onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageTitleSubtitle(
            title: "seed_generation".tr,
            body: Column(
              children: [
                Text("seed_generation_type".tr),
              ],
            )),
        AppRadioListTile(
          groupValue: seedGenerationType,
          title: Text("byron_legacy_seed".tr),
          value: SeedGenerationType.byronLegacySeed,
          onChanged: onChageSeedGeneration,
        ),
        AppRadioListTile(
          groupValue: seedGenerationType,
          value: SeedGenerationType.icarus,
          title: Text("icarus".tr),
          onChanged: onChageSeedGeneration,
        ),
        WidgetConstant.height20,
        ElevatedButton(onPressed: onContinue, child: Text("continue".tr))
      ],
    );
  }
}

class _GenerateAddress extends StatelessWidget {
  const _GenerateAddress({
    required this.network,
    required this.addrType,
    required this.generateAddress,
    required this.coin,
    required this.derivationStandard,
    required this.era,
    required this.onChangeDerivation,
    required this.onChangeShellyddrType,
    required this.setupKeyIndex,
    required this.standardDerivation,
    required this.masterKeyGenerationType,
    this.selectedCustomKey,
    this.customKeyIndex,
  });
  final APPCardanoNetwork network;
  final EncryptedCustomKey? selectedCustomKey;
  final AddressDerivationIndex? customKeyIndex;
  final bool derivationStandard;
  final _AdaEra era;
  final ADAAddressType addrType;
  final AddressDerivationIndex standardDerivation;
  final CryptoCoins coin;
  final _OnChangeShellyAddrType onChangeShellyddrType;
  final DynamicVoid generateAddress;
  final _OnChangeDerivation onChangeDerivation;
  final _SetupKeyIndex setupKeyIndex;
  final _CardanoMasterKeyGenerationType masterKeyGenerationType;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (era.isShelly)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height20,
              Text("shelley_address_format".tr,
                  style: context.textTheme.titleMedium),
              WidgetConstant.height8,
              AppDropDownBottom(
                  items: {
                    ADAAddressType.base: Text("base".tr),
                    ADAAddressType.reward: Text("reward".tr),
                    ADAAddressType.enterprise: Text("enterprise".tr),
                  },
                  value: addrType,
                  onChanged: onChangeShellyddrType,
                  label: "shelley_address_format".tr),
              WidgetConstant.height20,
            ],
          ),
        AppSwitchListTile(
          value: derivationStandard,
          onChanged: (p0) {
            onChangeDerivation(
              p0,
              () {
                if (masterKeyGenerationType.isLegacy) {
                  context
                      .openSliverBottomSheet<ByronLegacyAddressIndex>(
                          "key_derivation".tr,
                          child: ByronLegacyKeyDerivationView(
                            coin: coin,
                            curve: coin.conf.type,
                          ))
                      .then(setupKeyIndex);
                  return;
                }
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
              : Text(customKeyIndex?.path ?? "import_key_derivation_desc2".tr),
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
    );
  }
}
