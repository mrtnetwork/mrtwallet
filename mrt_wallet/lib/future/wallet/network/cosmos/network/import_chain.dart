import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

import 'update_native_token.dart';

enum _Page { selectChain, search, review }

typedef _OnAddOrUpdateTOken = Future<CosmosFeeToken?> Function(
    CosmosFeeToken? token);

class CosmosImportNetworkView extends StatefulWidget {
  const CosmosImportNetworkView({super.key});

  @override
  State<CosmosImportNetworkView> createState() =>
      _CosmosImportNetworkViewState();
}

class _CosmosImportNetworkViewState extends State<CosmosImportNetworkView>
    with HttpImpl, CosmosCustomRequest, ProgressMixin, SafeState {
  late final List<CosmosChain> existChains;
  late final WalletProvider wallet;
  ChainType? chaintype;
  Cancelable canclable = Cancelable();
  Map<ChainType, Widget> chainTypeWidgets = {};
  List<RegisteryPingPubItem> chains = [];
  List<RegisteryPingPubItem> filtredChains = [];
  final GlobalKey<AppTextFieldState> explorerFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> transactionFieldKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey();
  List<CosmosFeeToken> feeTokens = [];
  CosmosFeeToken? nativeToken;
  Map<CosmosKeysAlgs, Widget> keyAlgos = {};
  CosmosKeysAlgs? keyAlg;
  bool imutableKeyAlg = false;
  String explorerAddressLink = "";
  String explorerTransaction = "";
  String networkName = '';
  String hrp = '';
  RPCURL? rpcUrl;
  String? chainId;
  int slip44 = CosmosConst.defaultSlip44;

  void reset() {
    feeTokens = [];
    nativeToken = null;
    keyAlgos = buildKeyAlgos();
    keyAlg = keyAlgos.keys.first;
    imutableKeyAlg = false;
    explorerAddressLink = "";
    explorerTransaction = "";
    rpcUrl = null;
    chainId = null;
    slip44 = CosmosConst.defaultSlip44;
    hrp = '';
  }

  void setManuallyImport() {
    reset();
    page = _Page.review;
    updateState();
  }

  _Page page = _Page.selectChain;
  final GlobalKey<HTTPServiceProviderFieldsState> serviceProviderStateKey =
      GlobalKey(
          debugLabel: "_MoneroSyncOptionsViewState_serviceProviderStateKey");

  void changePage(_Page page) {
    this.page = page;
  }

  String? onValidateNetworkName(String v) {
    if (v.trim().isEmpty) {
      return "network_name_validator".tr;
    }
    return null;
  }

  Future<void> onUpdateNativeToken(_OnAddOrUpdateTOken onTap) async {
    final t = await onTap(nativeToken);
    if (t == null) return;
    nativeToken = t;
    updateState();
  }

  Future<void> onAddNewToken(_OnAddOrUpdateTOken onTap) async {
    final t = await onTap(null);
    if (t == null) return;
    if (feeTokens.any((e) => e.denom == t.denom)) {
      context.showAlert("token_already_exists".tr);
      return;
    }
    feeTokens.add(t);
    updateState();
  }

  Future<void> onRemoveFeeToken(
      CosmosFeeToken token, FuncFutureNullableBoold onRemove) async {
    final r = await onRemove();
    if (!(r ?? false)) return;
    feeTokens.remove(token);
    updateState();
  }

  void onChangeCoinType(int v) {
    slip44 = v;
  }

  String? validateCoinType(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final parse = int.tryParse(v ?? "");
    if (parse == null ||
        parse < 0 ||
        parse > Bip32KeyDataConst.keyIndexMaxVal) {
      return "slip_44_desc".tr;
    }
    return null;
  }

  void onChangeExplorerAddress(String v) {
    explorerAddressLink = v;
  }

  void onChangeExplorerTransaction(String v) {
    explorerTransaction = v;
  }

  void onChangeHrp(String v) {
    hrp = v;
  }

  String? onValidateHrp(String? v) {
    if (v?.isEmpty ?? true) return null;
    if (APPConst.hrpRegex.hasMatch(v!)) return null;
    return "enter_network_hrp_validator".tr;
  }

  Map<ChainType, Widget> buildChainType() {
    return {for (final i in ChainType.values) i: Text(i.tr.tr)};
  }

  Map<CosmosKeysAlgs, Widget> buildKeyAlgos(
      {List<CosmosKeysAlgs> keyTypes = CosmosKeysAlgs.supportedAlgs}) {
    return {for (final i in keyTypes) i: Text(i.name.camelCase)};
  }

  void onChangeKeyAlgs(CosmosKeysAlgs? alg) {
    if (alg == null) return;
    keyAlg = alg;
    updateState();
  }

  String? onValidateKeyAlgorithm(CosmosKeysAlgs? alg) {
    if (alg == null) return "select_key_algorithm_desc".tr;
    return null;
  }

  Future<void> getRelatedChains() async {
    progressKey.progressText("retrieving_chains".tr);
    final r = await MethodUtils.call(() {
      return getCosmosChains(chain: chaintype!);
    }, cancelable: canclable);
    if (r.hasResult) {
      chains = r.result;
      filtredChains = r.result;
      progressKey.success();
      return;
    }
    if (r.isCancel) return;
    progressKey.error();
  }

  String? validateAddressLink(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final link = StrUtils.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  void onSearchNetworkName(String v) {
    networkName = v;
    if (v.trim().isEmpty) {
      filtredChains = chains;
    } else {
      filtredChains = chains.where((e) {
        return e.name.contains(v.trim().toLowerCase());
      }).toList();
    }
    updateState();
  }

  void onChangeChainType(ChainType? chaintype) async {
    this.chaintype = chaintype;
    if (chaintype != null) {
      await getRelatedChains();
      page = _Page.search;
    } else {
      page = _Page.selectChain;
    }
    updateState();
  }

  Future<void> onSelectChain(RegisteryPingPubItem chainDirectory) async {
    progressKey.progressText("retrieving_network_condition".tr);

    final chainInfo = await MethodUtils.call(() async {
      final result = await getChainData(chainDirectory, chainType: chaintype!);
      if (existChains
          .any((e) => e.network.coinParam.chainId == result.chain.chainId)) {
        throw WalletException("network_chain_id_already_exist");
      }
      final chain = result.chain;
      final assets = result.assetList;
      final algs = chain.supportKeyAlgos();
      if (algs.isEmpty) {
        throw WalletException("unsupported_network_key_alg");
      }
      final chainId = chain.chainId;
      final List<CosmosFeeToken> feeTokens = [];
      CosmosFeeToken? nativeToken;
      final String? txExplorer = chain.explorers
          .elementAtOrNull(0)
          ?.getTxUrl(NetworkCoinParamsConst.txIdArgs);
      final String? addressExplorer = chain.explorers
          .elementAtOrNull(0)
          ?.getAccountUrl(NetworkCoinParamsConst.addrArgs);
      for (final i in chain.fees.feeTokens) {
        final asset = assets.assets.firstWhereOrNull((e) => e.base == i.denom);
        final List<String> images = asset?.assetImageUrls ?? [];
        final int exponent = asset?.denomUnits
                .firstWhere((e) => e.denom == asset.display)
                .exponent ??
            CosmosConst.maxTokenExponent;
        final token = CosmosFeeToken(
          token: Token(
              assetLogo: images.isEmpty ? null : APPImage.network(images.first),
              name: asset?.name ?? i.denom,
              symbol: asset?.display ?? i.denom,
              decimal: exponent,
              market: asset?.coingeckoId != null
                  ? CoingeckoCoin(apiId: asset!.coingeckoId!)
                  : null),
          denom: i.denom,
          averageGasPrice:
              BigRational.tryParseDecimaal(i.averageGasPrice.toString()),
          highGasPrice: BigRational.tryParseDecimaal(i.highGasPrice.toString()),
          lowGasPrice: BigRational.tryParseDecimaal(i.lowGasPrice.toString()),
        );
        feeTokens.add(token);
      }
      if (chain.staking.stakingTokens.isNotEmpty) {
        final stakingDenom = chain.staking.stakingTokens
            .firstWhere(
              (e) => feeTokens.any((f) => f.denom == e.denom),
              orElse: () => chain.staking.stakingTokens.first,
            )
            .denom;
        nativeToken =
            feeTokens.firstWhereOrNull((e) => e.denom == stakingDenom);
        if (nativeToken == null) {
          final asset =
              assets.assets.firstWhereOrNull((e) => e.base == stakingDenom);
          final List<String> images = asset?.assetImageUrls ?? [];
          final int exponent = asset?.denomUnits
                  .firstWhere((e) => e.denom == asset.display)
                  .exponent ??
              CosmosConst.maxTokenExponent;
          nativeToken = CosmosFeeToken(
              token: Token(
                  assetLogo:
                      images.isEmpty ? null : APPImage.network(images.first),
                  name: chain.chainName,
                  symbol: asset?.display ?? stakingDenom,
                  decimal: exponent,
                  market: asset?.coingeckoId != null
                      ? CoingeckoCoin(apiId: asset!.coingeckoId!)
                      : null),
              denom: stakingDenom);
        }
      }
      final List<CosmosAPIProvider> providers = [];
      if (chain.apis.rpc.isNotEmpty) {
        final provider = CosmosAPIProvider(
            uri: chain.apis.rpc.first.address,
            identifier: APIUtils.getProviderIdentifier());
        providers.add(provider);
      }
      final slip44 = chain.slip44 ?? CosmosConst.defaultSlip44;
      final networkParams = CosmosNetworkInfo(
          nativeToken: nativeToken,
          providers: providers,
          networkName: chain.chainName,
          hrp: chain.bech32Prefix ?? '',
          feeTokens: feeTokens,
          networkType: CosmosNetworkTypes.forked,
          chainId: chainId ?? '',
          slip44: slip44,
          keysAlgs: algs,
          addressExplorer: addressExplorer,
          transactionExplorer: txExplorer);
      return networkParams;
    }, cancelable: canclable);

    if (chainInfo.hasError) {
      if (chainInfo.isCancel) return;
      progressKey.errorText(chainInfo.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final coinParams = chainInfo.result;
    keyAlgos = buildKeyAlgos(keyTypes: coinParams.keysAlgs);
    keyAlg = coinParams.keysAlgs.first;
    explorerAddressLink = coinParams.addressExplorer ?? "";
    explorerTransaction = coinParams.transactionExplorer ?? "";
    slip44 = coinParams.slip44;
    chainId = coinParams.chainId;
    nativeToken = coinParams.nativeToken;
    feeTokens = coinParams.feeTokens;
    hrp = coinParams.hrp ?? '';
    if (coinParams.providers.isNotEmpty) {
      rpcUrl = RPCURL(url: coinParams.providers.first.callUrl);
    }
    progressKey.success();
    page = _Page.review;
    updateState();
  }

  void init() {
    chainTypeWidgets = buildChainType();
    keyAlgos = buildKeyAlgos();
    wallet = context.watch<WalletProvider>(StateConst.main);
    existChains = wallet.wallet.getChains<CosmosChain>();
  }

  void onBackButton() {
    canclable.cancel();
    progressKey.backToIdle();
    onChangeChainType(null);
    reset();
  }

  CosmosNetworkParams buildCoinParams() {
    return CosmosNetworkParams(
      token: nativeToken!.token,
      providers: [],
      chainType: chaintype!,
      hrp: hrp,
      denom: nativeToken!.denom,
      feeTokens: feeTokens,
      networkType: CosmosNetworkTypes.forked,
      chainId: chainId ?? '',
      keysAlgs: keyAlgos.keys.toList(),
      bip32CoinType: slip44,
      addressExplorer: explorerAddressLink.nullOnEmpty,
      transactionExplorer: explorerTransaction.nullOnEmpty,
    );
  }

  Future<void> validateRpc() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    rpcUrl = serviceProviderStateKey.currentState?.getEndpoint();
    if (rpcUrl == null) return;

    progressKey.progressText("checking_rpc_network_info".tr);

    final provider = CosmosAPIProvider(
        uri: rpcUrl!.url,
        auth: rpcUrl!.auth,
        identifier: APIUtils.getProviderIdentifier());
    final params = await MethodUtils.call(() {
      return buildNetwork(provider: provider, param: buildCoinParams());
    });
    if (params.hasError) {
      progressKey.errorText(params.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final result = await MethodUtils.call(() async {
      return wallet.wallet
          .updateImportNetwork(WalletCosmosNetwork(-1, params.result));
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusableChild(
      child: Scaffold(
        appBar: AppBar(
          title: Text("import_network".tr),
        ),
        body: PopScope(
          canPop: chaintype == null,
          onPopInvokedWithResult: (didPop, result) {
            onBackButton();
          },
          child: PageProgress(
            key: progressKey,
            backToIdle: APPConst.oneSecoundDuration,
            child: (context) {
              return CustomScrollView(
                slivers: [
                  APPSliverAnimatedSwitcher<_Page>(
                    enable: page,
                    widgets: {
                      _Page.selectChain: (context) => _SelectChainType(this),
                      _Page.search: (context) => _SelectNetwork(this),
                      _Page.review: (context) => _Review(this),
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectChainType extends StatelessWidget {
  const _SelectChainType(this.state);
  final _CosmosImportNetworkViewState state;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: WidgetConstant.paddingHorizontal20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("chain_type".tr, style: context.textTheme.titleMedium),
            Text("select_cosmos_chain_type_desc".tr),
            WidgetConstant.height8,
            AppDropDownBottom<ChainType>(
              items: state.chainTypeWidgets,
              value: state.chaintype,
              hint: "chain_type".tr,
              onChanged: state.onChangeChainType,
            )
          ],
        ),
      ),
    );
  }
}

class _SelectNetwork extends StatelessWidget {
  const _SelectNetwork(this.state);
  final _CosmosImportNetworkViewState state;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverPinnedHeaderSurface(
        elevation: APPConst.elevation,
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("network_name".tr, style: context.textTheme.titleMedium),
              Text("select_network_to_import_desc".tr),
              WidgetConstant.height8,
              AppTextField(
                label: "network_name".tr,
                onChanged: state.onSearchNetworkName,
                prefixIcon: Icon(Icons.search),
                initialValue: state.networkName,
              ),
            ],
          ),
        ),
      ),
      SliverConstraintsBoxView(
        padding: WidgetConstant.paddingHorizontal20,
        sliver: ConditionalWidget(
          enable: state.filtredChains.isNotEmpty,
          onDeactive: (context) {
            return SliverFillRemaining(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "chain_not_found_import_manually_desc".tr,
                    textAlign: TextAlign.center,
                  ),
                  WidgetConstant.height8,
                  FixedElevatedButton(
                      onPressed: state.setManuallyImport,
                      child: Text("import_manually".tr)),
                ],
              ),
            );
          },
          onActive: (context) => SliverList.separated(
            itemBuilder: (context, index) {
              final chain = state.filtredChains[index];
              return AppListTile(
                title: Text(chain.name),
                onTap: () => state.onSelectChain(chain),
              );
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: state.filtredChains.length,
          ),
        ),
      ),
    ]);
  }
}

class _Review extends StatelessWidget {
  const _Review(this.state);
  final _CosmosImportNetworkViewState state;

  @override
  Widget build(BuildContext context) {
    return SliverPageConstraintsBoxView(
        sliver: SliverMainAxisGroup(
      slivers: [
        SliverPinnedHeaderSurface(
          child: ErrorTextContainer(
              error: "import_network_experimental_feature_desc".tr),
        ),
        SliverToBoxAdapter(
          child: Form(
            key: state.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetConstant.height20,
                Text("native_token".tr, style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                FormField(
                  validator: (value) {
                    return state.nativeToken == null
                        ? "network_token_required".tr
                        : null;
                  },
                  builder: (f) => _CosmosTokenView(
                      validate: f.isValid,
                      validateError: f.errorText,
                      onTap: () {
                        state.onUpdateNativeToken(
                          (token) {
                            return context.openSliverBottomSheet(
                                token == null
                                    ? "setup_token".tr
                                    : "update_token".tr,
                                child: UpdateCosmosTokenView(token: token),
                                initialExtend: 1);
                          },
                        );
                      },
                      token: state.nativeToken),
                ),
                WidgetConstant.height20,
                Text("fee_tokens".tr, style: context.textTheme.titleMedium),
                Text("cosmos_fee_token_desc".tr),
                WidgetConstant.height8,
                ...List.generate(state.feeTokens.length, (i) {
                  final token = state.feeTokens[i];
                  return _CosmosTokenView(
                      enableTap: false,
                      onRemoveIcon: Icon(Icons.remove_circle,
                          color: context.onPrimaryContainer),
                      onTap: () {
                        state.onRemoveFeeToken(
                          token,
                          () => context.openSliverDialog<bool>(
                            (context) => DialogTextView(
                              text: "remove_token_from_fee_token_list_desc".tr,
                              buttonWidget: const DialogDoubleButtonView(),
                            ),
                            "remove_token".tr,
                          ),
                        );
                      },
                      token: token);
                }),
                FormField(validator: (value) {
                  if (state.feeTokens.isNotEmpty) return null;
                  return "at_least_one_fee_token_required".tr;
                }, builder: (f) {
                  return _CosmosTokenView(
                      validate: f.isValid,
                      validateError: f.errorText,
                      onTap: () {
                        state.onAddNewToken(
                          (token) {
                            return context.openSliverBottomSheet(
                                "setup_token".tr,
                                child: UpdateCosmosTokenView(
                                  token: token,
                                  isFeeToken: true,
                                ),
                                initialExtend: 1);
                          },
                        );
                      },
                      onNullTokenMessage: "tap_to_add_new_fee_token".tr);
                }),
                WidgetConstant.height20,
                Text("key_alg".tr, style: context.textTheme.titleMedium),
                Text("cosmos_key_alg_desc".tr),
                if (!state.imutableKeyAlg) Text("cosmos_key_alg_desc2".tr),
                WidgetConstant.height8,
                IgnorePointer(
                  ignoring: state.imutableKeyAlg,
                  child: AppDropDownBottom(
                    items: state.keyAlgos,
                    value: state.keyAlg,
                    hint: "key_alg".tr,
                    onChanged: state.onChangeKeyAlgs,
                    validator: state.onValidateKeyAlgorithm,
                  ),
                ),
                WidgetConstant.height20,
                Text("coin_type".tr, style: context.textTheme.titleMedium),
                LargeTextView(["slip_44_desc".tr, "coin_type_desc2".tr],
                    maxLine: 1),
                WidgetConstant.height8,
                NumberTextField(
                    label: "coin_type".tr,
                    defaultValue: state.slip44,
                    onChange: state.onChangeCoinType,
                    validator: state.validateCoinType,
                    max: Bip32KeyDataConst.keyIndexMaxVal,
                    min: 0),
                WidgetConstant.height20,
                //
                WidgetConstant.height20,
                Text("address_prefix_hrp".tr,
                    style: context.textTheme.titleMedium),
                Text("cosmos_enter_hrp_desc".tr),
                WidgetConstant.height8,
                AppTextField(
                  initialValue: state.hrp,
                  onChanged: state.onChangeHrp,
                  validator: state.onValidateHrp,
                  label: "address_prefix_hrp".tr,
                  pasteIcon: true,
                ),
                WidgetConstant.height20,
                //
                Text("network_explorer_address_link".tr,
                    style: context.textTheme.titleMedium),
                LargeTextView(["network_evm_explorer_address_desc".tr],
                    maxLine: 1),
                WidgetConstant.height8,
                AppTextField(
                  key: state.explorerFieldKey,
                  initialValue: state.explorerAddressLink,
                  onChanged: state.onChangeExplorerAddress,
                  validator: state.validateAddressLink,
                  label: "network_explorer_address_link".tr,
                  pasteIcon: true,
                ),
                WidgetConstant.height20,
                Text("network_explorer_transaction_link".tr,
                    style: context.textTheme.titleMedium),
                LargeTextView(["network_evm_explorer_transaction_desc".tr],
                    maxLine: 1),
                WidgetConstant.height8,
                AppTextField(
                  key: state.transactionFieldKey,
                  initialValue: state.explorerTransaction,
                  onChanged: state.onChangeExplorerTransaction,
                  validator: state.validateAddressLink,
                  label: "network_explorer_transaction_link".tr,
                  pasteIcon: true,
                ),
                WidgetConstant.height20,
                Text("rpc_url".tr, style: context.textTheme.titleMedium),
                Text("enter_tendermint_rpc_desc".tr),
                WidgetConstant.height8,
                HTTPServiceProviderFields(
                    key: state.serviceProviderStateKey,
                    initialUrl: state.rpcUrl,
                    enableAuth: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        onPressed: state.validateRpc,
                        child: Text("import".tr))
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class _CosmosTokenView extends StatelessWidget {
  const _CosmosTokenView(
      {required this.onTap,
      this.onNullTokenMessage,
      this.token,
      this.validate = true,
      this.validateError,
      this.enableTap = true,
      this.onRemoveIcon});
  final CosmosFeeToken? token;
  final DynamicVoid onTap;
  final String? onNullTokenMessage;
  final bool validate;
  final String? validateError;
  final bool enableTap;
  final Widget? onRemoveIcon;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      validate: validate,
      validateText: validateError,
      enableTap: enableTap,
      onRemoveIcon: onRemoveIcon ?? AddOrEditIconWidget(token != null),
      iconAlginment:
          token == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      onRemove: onTap,
      child: APPAnimatedSwitcher(
          width: context.mediaQuery.size.width,
          enable: token != null,
          widgets: {
            false: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(onNullTokenMessage ?? "tap_to_setup_native_token".tr,
                        style: context.onPrimaryTextTheme.bodyMedium),
                  ],
                ),
            true: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("token_info".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: TokenDetailsWidget(
                          token: token!.token,
                          color: context.primaryContainer,
                          radius: APPConst.circleRadius25),
                    ),
                    WidgetConstant.height20,
                    Text("decimals".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: Text(token!.token.decimal!.toString(),
                          style: context.primaryTextTheme.bodyMedium),
                    ),
                  ],
                )
          }),
    );
  }
}
