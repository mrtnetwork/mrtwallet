import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

import 'update_native_token.dart';

enum _Page { selectChain, search, review }

class CosmosImportNetworkView extends StatelessWidget {
  const CosmosImportNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      appbar: AppBar(title: Text("import_network".tr)),
      onAccsess: (credential, password, network) {
        return _CosmosImportNetworkView();
      },
    );
  }
}

class _CosmosImportNetworkView extends StatefulWidget {
  const _CosmosImportNetworkView();

  @override
  State<_CosmosImportNetworkView> createState() =>
      __CosmosImportNetworkViewState();
}

class __CosmosImportNetworkViewState extends State<_CosmosImportNetworkView>
    with HttpImpl, CosmosCustomRequest, ProgressMixin, SafeState {
  final form = CosmosAddNewChainFrom();
  late final List<CosmosChain> existChains;
  String? networkName;
  Map<ChainType, Widget> chainTypeWidgets = {};
  late final WalletProvider wallet;
  Map<ChainType, Widget> buildChainType() {
    return {for (final i in ChainType.values) i: Text(i.tr.tr)};
  }

  ChainType? chaintype;
  _Page page = _Page.selectChain;
  List<CosmosSdkChain> chains = [];
  List<CosmosSdkChain> filtredChains = [];
  void onSelectChain(CosmosSdkChain chain) {
    form.buildFrom(chain);
    page = _Page.review;
    updateState();
  }

  void setManuallyImport() {
    form.buildFrom(null);
    page = _Page.review;
    updateState();
  }

  void changePage(_Page page) {
    this.page = page;
  }

  void onChangeChainType(ChainType? chaintype) async {
    this.chaintype = chaintype;
    switch (chaintype) {
      case ChainType.mainnet:
        chains = form.chains?.mainnet ?? [];
        filtredChains = form.chains?.mainnet ?? [];
        page = _Page.search;
        break;
      case ChainType.testnet:
        chains = form.chains?.testnet ?? [];
        filtredChains = form.chains?.testnet ?? [];
        page = _Page.search;
        break;
      default:
        page = _Page.selectChain;
        break;
    }
    updateState();
  }

  void onSearchNetworkName(String v) {
    if (v.trim().isEmpty) {
      filtredChains = chains;
    } else {
      filtredChains = chains.where((e) {
        return e.name.contains(v.trim().toLowerCase());
      }).toList();
    }
    updateState();
  }

  Future<void> init() async {
    await MethodUtils.call(() => form.initForm());
    form.onChanged = updateState;
    chainTypeWidgets = buildChainType();
    wallet = context.wallet;
    existChains = wallet.wallet.getChains<CosmosChain>();
    progressKey.backToIdle();
  }

  Future<void> importChain() async {
    if (!(form.formKey.currentState?.validate() ?? false)) return;
    final rpcUrl = form.getRpcUrl();
    if (rpcUrl == null) return;
    progressKey.progressText("checking_rpc_network_info".tr);

    final params = await MethodUtils.call(() {
      return form.createNetwork(chainType: chaintype);
    });
    if (params.hasError) {
      progressKey.errorText(params.error!.tr,
          backToIdle: false, showBackButton: true);
      return;
    }
    final network = params.result;
    if (network == null) {
      progressKey.errorText("some_required_field_not_filled".tr);
      return;
    }
    final newNetwork = WalletCosmosNetwork(-1, network);
    final result = await MethodUtils.call(() async {
      return wallet.wallet.updateImportNetwork(newNetwork);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          backToIdle: false, showBackButton: true);
    } else {
      progressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
    }
    updateState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() async => init());
  }

  Future<void> onBackButton() async {
    if (progressKey.inProgress || progressKey.isSuccess) return;
    if (progressKey.hasError) {
      progressKey.backToIdle();
      return;
    }
    if (page == _Page.review) {
      final close = await context.openSliverDialog<bool>(
          (p0) => DialogTextView(
                text: "all_entered_information_will_be_lost".tr,
                buttonWidget: const DialogDoubleButtonView(),
              ),
          "back_to_previous_page".tr);
      if (close != true) return;
    }
    onChangeChainType(null);
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusableChild(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          onBackButton();
        },
        canPop: chaintype == null || progressKey.isSuccess,
        child: PageProgress(
          key: progressKey,
          initialStatus: StreamWidgetStatus.progress,
          initialWidget: ProgressWithTextView(text: "retrieving_chains".tr),
          backToIdle: APPConst.oneSecoundDuration,
          child: (context) {
            return CustomScrollView(
              slivers: [
                APPSliverAnimatedSwitcher<_Page>(
                  enable: page,
                  widgets: {
                    _Page.selectChain: (context) => _SelectChainType(this),
                    _Page.search: (context) => _SelectNetwork(this),
                    _Page.review: (context) => CosmosImportNetworkFieldsView(
                        form: form, onImport: importChain),
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SelectChainType extends StatelessWidget {
  const _SelectChainType(this.state);
  final __CosmosImportNetworkViewState state;

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
                onChanged: state.onChangeChainType)
          ],
        ),
      ),
    );
  }
}

class _SelectNetwork extends StatelessWidget {
  const _SelectNetwork(this.state);
  final __CosmosImportNetworkViewState state;

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
                title: Text(chain.chainName),
                subtitle: Text(chain.chainId),
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

class CosmosImportNetworkFieldsView extends StatelessWidget {
  const CosmosImportNetworkFieldsView(
      {super.key, required this.form, required this.onImport});
  final CosmosAddNewChainFrom form;
  final DynamicVoid onImport;

  @override
  Widget build(BuildContext context) {
    return SliverPageConstraintsBoxView(
        sliver: SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Form(
            key: form.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AlertTextContainer(
                    message: "import_network_experimental_feature_desc".tr),
                WidgetConstant.height20,
                Text("native_token".tr, style: context.textTheme.titleMedium),
                WidgetConstant.height8,
                FormField(
                  validator: (value) {
                    return form.nativeToken == null
                        ? "network_token_required".tr
                        : null;
                  },
                  builder: (f) => _CosmosTokenView(
                      validate: f.isValid,
                      validateError: f.errorText,
                      onTap: () {
                        form.onUpdateNativeToken(
                          (token) {
                            return context.openSliverBottomSheet(
                              token == null
                                  ? "setup_token".tr
                                  : "update_token".tr,
                              child: UpdateCosmosTokenView(token: token),
                            );
                          },
                        );
                      },
                      token: form.nativeToken),
                ),
                WidgetConstant.height20,
                Text("fee_tokens".tr, style: context.textTheme.titleMedium),
                Text("cosmos_fee_token_desc".tr),
                WidgetConstant.height8,
                ...List.generate(form.feeTokens.length, (i) {
                  final token = form.feeTokens[i];
                  return _CosmosTokenView(
                      enableTap: false,
                      isFeeToken: true,
                      onRemoveIcon: Icon(Icons.remove_circle,
                          color: context.onPrimaryContainer),
                      onTap: () {
                        form.onRemoveFeeToken(
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
                  if (form.feeTokens.isNotEmpty) return null;
                  return "at_least_one_fee_token_required".tr;
                }, builder: (f) {
                  return _CosmosTokenView(
                      validate: f.isValid,
                      validateError: f.errorText,
                      onTap: () {
                        form.onAddNewToken((token) {
                          return context.openSliverBottomSheet(
                            "setup_token".tr,
                            child: UpdateCosmosTokenView(
                              token: token,
                              isFeeToken: true,
                            ),
                          );
                        }, () {
                          context.showAlert("token_already_exists".tr);
                        });
                      },
                      onNullTokenMessage: "tap_to_add_new_fee_token".tr);
                }),
                WidgetConstant.height20,
                Text("key_alg".tr, style: context.textTheme.titleMedium),
                Text("cosmos_key_alg_desc".tr),
                _ShowKeyAlgs(form),
                WidgetConstant.height20,
                Text("coin_type".tr, style: context.textTheme.titleMedium),
                LargeTextView(["slip_44_desc".tr, "coin_type_desc2".tr],
                    maxLine: 1),
                WidgetConstant.height8,
                NumberTextField(
                    label: "coin_type".tr,
                    defaultValue: form.slip44,
                    onChange: form.onChangeCoinType,
                    validator: form.validateCoinType,
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
                  initialValue: form.hrp,
                  onChanged: form.onChangeHrp,
                  validator: form.onValidateHrp,
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
                  key: form.explorerFieldKey,
                  initialValue: form.explorerAddressLink,
                  onChanged: form.onChangeExplorerAddress,
                  validator: form.validateAddressLink,
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
                  key: form.transactionFieldKey,
                  initialValue: form.explorerTransaction,
                  onChanged: form.onChangeExplorerTransaction,
                  validator: form.validateAddressLink,
                  label: "network_explorer_transaction_link".tr,
                  pasteIcon: true,
                ),
                WidgetConstant.height20,
                Text("rpc_url".tr, style: context.textTheme.titleMedium),
                Text("enter_tendermint_rpc_desc".tr),
                WidgetConstant.height8,
                HTTPServiceProviderFields(
                  key: form.serviceProviderStateKey,
                  initialUrl: form.rpcUrl,
                  enableAuth: true,
                  protocols: [ServiceProtocol.http],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FixedElevatedButton(
                        padding: WidgetConstant.paddingVertical40,
                        activePress: form.supportedKeyAlg,
                        onPressed: onImport,
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
      this.onRemoveIcon,
      this.isFeeToken = false});
  final CosmosFeeToken? token;
  final DynamicVoid onTap;
  final String? onNullTokenMessage;
  final bool validate;
  final String? validateError;
  final bool enableTap;
  final Widget? onRemoveIcon;
  final bool isFeeToken;

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
                            style: context.primaryTextTheme.bodyMedium)),
                    if (isFeeToken) ...[
                      WidgetConstant.height20,
                      Text("avarage_gas_price".tr,
                          style: context.onPrimaryTextTheme.titleMedium),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          child: CoinPriceView(
                            token: token!.token,
                            balance: token!.averageGasPrice,
                            symbolColor: context.primaryContainer,
                            style: context.primaryTextTheme.titleMedium,
                          )),
                    ]
                  ],
                )
          }),
    );
  }
}

class _ShowKeyAlgs extends StatelessWidget {
  final CosmosAddNewChainFrom form;
  const _ShowKeyAlgs(this.form);

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
        enable: form.unknowKeyAlg,
        onActive: (context) {
          return Column(
            children: [
              AlertTextContainer(message: "cosmos_key_alg_desc2".tr),
              WidgetConstant.height8,
              AppDropDownBottom(
                  items: form.keyAlgos,
                  value: form.keyAlg,
                  hint: "key_alg".tr,
                  onChanged: form.onChangeKeyAlgs,
                  validator: form.onValidateKeyAlgorithm),
            ],
          );
        },
        onDeactive: (context) {
          return Column(
            children: [
              if (!form.supportedKeyAlg)
                ErrorTextContainer(error: "unsupported_network_key_alg".tr),
              WidgetConstant.height8,
              ListView.builder(
                  itemBuilder: (context, index) {
                    final key = form.supportedAlgs[index];
                    return ContainerWithBorder(
                      enableTap: false,
                      onRemove: () {},
                      onRemoveWidget: TappedTooltipView(
                          tooltipWidget: ToolTipView(
                        message: key.supported
                            ? 'support_by_application'.tr
                            : 'unsupported_by_application'.tr,
                        child: ConditionalWidget(
                            enable: key.supported,
                            onDeactive: (context) => Icon(Icons.close,
                                color: context.onPrimaryContainer),
                            onActive: (context) => Icon(Icons.check_circle,
                                color: context.onPrimaryContainer)),
                      )),
                      child: Text(key.alg,
                          style: context.onPrimaryTextTheme.bodyMedium),
                    );
                  },
                  itemCount: form.supportedAlgs.length,
                  physics: WidgetConstant.noScrollPhysics,
                  shrinkWrap: true),
            ],
          );
        });
  }
}
