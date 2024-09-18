import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/slip/slip44/slip44.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/utils/ethereum/utils.dart';
import 'package:mrt_wallet/crypto/utils/utils.dart';

enum _Page { chainId, infos }

class ImportEthereumNetwork extends StatelessWidget {
  const ImportEthereumNetwork({super.key}) : web3 = null;
  final EthereumWeb3Form<Web3EthereumAddNewChain>? web3;
  const ImportEthereumNetwork.fromWeb3(
      EthereumWeb3Form<Web3EthereumAddNewChain> this.web3,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final WalletEthereumNetwork? network = context.getNullArgruments();
    return _ImportEthereumNetwork(network: network, web3: web3);
  }
}

class _ImportEthereumNetwork extends StatefulWidget {
  const _ImportEthereumNetwork({this.network, this.web3});
  final WalletEthereumNetwork? network;
  final EthereumWeb3Form<Web3EthereumAddNewChain>? web3;
  @override
  State<_ImportEthereumNetwork> createState() => __ImportEthereumNetworkState();
}

class __ImportEthereumNetworkState extends State<_ImportEthereumNetwork>
    with SafeState {
  late final WalletEthereumNetwork network;
  late final bool isWalletNetwork = network.isWalletNetwork;
  late final bool isDefaultNetwork = network.coinParam.defaultNetwork;
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  final GlobalKey<AppTextFieldState> explorerFieldKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "form key!");
  final GlobalKey<AppTextFieldState> transactionFieldKey = GlobalKey();
  late final List<BigInt> existsChainIds;
  late String symbol = network.coinParam.token.symbol;
  late String networkName = network.coinParam.token.name;
  late BigInt chainId = network.coinParam.chainId;
  late int coinType = network.coinParam.bip32CoinType ?? Slip44.ethereum;
  late String explorerAddressLink = network.coinParam.addressExplorer ?? "";
  late String explorerTransaction = network.coinParam.transactionExplorer ?? "";
  late final bool editableChainId = !isWalletNetwork && widget.web3 == null;
  late final bool isWeb3 = widget.web3 != null;
  EthereumChain? chain;
  bool get hasProvider =>
      defaultProviders.isNotEmpty || importedProviders.isNotEmpty;

  void onChangeSymbol(String v) {
    symbol = v;
  }

  void onChangeNetworkName(String v) {
    networkName = v;
  }

  void onChangeExplorerAddress(String v) {
    explorerAddressLink = v;
  }

  void onChangeExplorerTransaction(String v) {
    explorerTransaction = v;
  }

  String? chainError;
  void onChangeChainId(int v) {
    chainId = BigInt.from(v);
    if (chainError != null) {
      chainError = null;
      updateState();
    }
    final exists = existsChainIds.contains(chainId);
    if (exists) {
      chainError = "network_chain_id_already_exist".tr;
      updateState();
    }
  }

  void onChangeCoinType(int v) {
    coinType = v;
  }

  void changeChainId() {
    if (!editableChainId) return;
    page = _Page.chainId;
    updateState();
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

  String? validateChainId(String? v) {
    final toInt = BigInt.tryParse(v ?? "");
    if (toInt == null) return "chain_id_validator".tr;
    return null;
  }

  String? validateNetworkName(String? v) {
    if ((v?.isEmpty ?? true) || v!.length < 2 || v.length > 25) {
      return "network_name_validator".tr;
    }
    return null;
  }

  String? validateRpcUrl(String? v) {
    final path =
        StrUtils.validateUri(v, schame: ["http", "https", "ws", "wss"]);
    if (path == null) return "rpc_url_validator".tr;
    return null;
  }

  String? validateSymbol(String? v) {
    if ((v?.isEmpty ?? true) || v!.isEmpty || v.length > 6) {
      return "symbol_validator".tr;
    }
    return null;
  }

  String? validateAddressLink(String? v) {
    if (v?.trim().isEmpty ?? true) return null;
    final link = StrUtils.validateUri(v);
    if (link == null) return "validate_link_desc".tr;
    return null;
  }

  late final List<EthereumAPIProvider> defaultProviders;

  late List<EthereumAPIProvider> importedProviders =
      List.from(network.coinParam.providers);

  _Page page = _Page.infos;

  void confirmChainId() {
    if (formKey.currentState?.validate() ?? false) {
      page = _Page.infos;
      updateState();
    }
  }

  void onTapUpdateProviders() async {
    final to = await context.to<List<EthereumAPIProvider>>(
        PageRouter.updateEthereumProvider,
        argruments: (chainId, importedProviders));
    if (to != null) {
      importedProviders = to;
      updateState();
    }
  }

  void onRemoveProvider(APIProvider provider) {
    importedProviders.remove(provider);
    updateState();
  }

  late WalletProvider wallet;
  bool get showRemoveIcon =>
      chain != null && isWalletNetwork && !isDefaultNetwork;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async {
      wallet = context.watch<WalletProvider>(StateConst.main);
      final evmNetworks =
          wallet.wallet.getChains().whereType<EthereumChain>().toList();

      if (widget.web3 == null) {
        network = widget.network ?? WalletEthereumNetwork.create();
        final networkExist = evmNetworks
            .firstWhereOrNull((e) => e.chainId == network.coinParam.chainId);
        chain = networkExist;
      } else {
        final web3Network = widget.web3!.request.params.toNewNetwork();
        final networkExist = evmNetworks.firstWhereOrNull(
            (e) => e.chainId == web3Network.coinParam.chainId);
        network = networkExist?.network ?? web3Network;

        if (networkExist != null) {
          importedProviders.addAll(web3Network.coinParam.providers);
        }
      }

      existsChainIds = evmNetworks.map((e) => e.chainId).toList();
      defaultProviders = List<EthereumAPIProvider>.unmodifiable(
          ProvidersConst.getDefaultProvider(network));
      if (editableChainId) {
        page = _Page.chainId;
      }
      pageProgressKey.backToIdle();
      updateState();
    });
  }

  void removeChain(bool? remove) async {
    if (remove != true) return;
    pageProgressKey.progressText("removing_chain_please_wait".tr);
    final result = await wallet.wallet.removeChain(chain!);
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.successText("chain_removed_desc".tr, backToIdle: false);
    }
  }

  void onAddChain() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!hasProvider) return;
    pageProgressKey.progressText("checking_rpc_network_info".tr);
    final result = await MethodUtils.call(() async {
      final wallet = context.watch<WalletProvider>(StateConst.main);
      final chain = chainId;
      WalletEthereumNetwork updateNetwork;
      if (isDefaultNetwork) {
        updateNetwork = network.copyWith(
            coinParam: network.coinParam.updateProviders(importedProviders));
      } else {
        final client =
            APIUtils.buildEthereumProvider(importedProviders[0], network);
        final info = await client.getNetworkInfo();
        updateNetwork = network.copyWith(
            coinParam: EthereumNetworkParams(
                transactionExplorer: explorerTransaction.nullOnEmpty,
                addressExplorer: explorerAddressLink.nullOnEmpty,
                token: Token(
                    name: networkName,
                    symbol: symbol,
                    decimal: EthereumUtils.decimal),
                providers: importedProviders,
                chainId: chain,
                supportEIP1559: info.$2,
                defaultNetwork: false,
                mainnet: true,
                bip32CoinType: coinType));
      }
      return await wallet.wallet.updateImportNetwork(updateNetwork);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.successText("network_imported_to_your_wallet".tr,
          backToIdle: false);
      widget.web3?.onCompeleteForm?.call(chainId.toRadix16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: isWeb3
          ? null
          : AppBar(
              title: Text("import_network".tr),
              actions: [
                if (showRemoveIcon)
                  TextButton.icon(
                    onPressed: () {
                      context
                          .openSliverDialog<bool>(
                              (p0) => DialogTextView(
                                    widget: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("remove_network_desc2".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        WidgetConstant.height8,
                                        Text("remove_network_desc".tr),
                                      ],
                                    ),
                                    buttonWidget:
                                        const DialogDoubleButtonView(),
                                  ),
                              "remove_network".tr)
                          .then(removeChain);
                    },
                    label: Text("remove".tr),
                    icon: Icon(Icons.delete, color: context.colors.error),
                  )
              ],
            ),
      child: Form(
        key: formKey,
        child: UnfocusableChild(
          child: PageProgress(
            key: pageProgressKey,
            initialStatus: StreamWidgetStatus.progress,
            backToIdle: APPConst.oneSecoundDuration,
            child: (c) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: WidgetConstant.padding20,
                  sliver: SliverConstraintsBoxView(
                      sliver: SliverMainAxisGroup(slivers: [
                    SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          PageTitleSubtitle(
                              title: "import_new_network".tr,
                              body: LargeTextView([
                                "import_new_network_desc1".tr,
                                "import_new_network_desc2".tr
                              ])),
                        ])),
                    APPSliverAnimatedSwitcher(enable: page, widgets: {
                      _Page.chainId: (c) => _SetupChainId(this),
                      _Page.infos: (c) => _ChainInfos(this)
                    }),
                  ])),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupChainId extends StatelessWidget {
  const _SetupChainId(this.state, {Key? key}) : super(key: key);
  final __ImportEthereumNetworkState state;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("chain_id".tr, style: context.textTheme.titleMedium),
          Text("chain_id_desc".tr),
          WidgetConstant.height8,
          NumberTextField(
              label: "chain_id".tr,
              defaultValue: state.chainId.toInt(),
              onChange: state.onChangeChainId,
              validator: state.validateChainId,
              error: state.chainError,
              showPasteIcon: true,
              // suffixIcon: PasteTextIcon(onPaste: (v) {}, isSensitive: false),
              max: null,
              min: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical40,
                onPressed: state.confirmChainId,
                child: Text("confirm_chain_id".tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChainInfos extends StatelessWidget {
  const _ChainInfos(this.state, {Key? key}) : super(key: key);
  final __ImportEthereumNetworkState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("chain_id".tr, style: context.textTheme.titleMedium),
          Text("chain_id_of_network".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
            onRemoveIcon:
                Icon(Icons.edit, color: context.colors.onPrimaryContainer),
            onRemove: !state.editableChainId
                ? null
                : () {
                    state.changeChainId();
                  },
            child: Text(
              state.chainId.toString(),
              style: context.colors.onPrimaryContainer.bodyMedium(context),
            ),
          ),
          WidgetConstant.height20,
          Text("network_name".tr, style: context.textTheme.titleMedium),
          Text("network_name_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            initialValue: state.networkName,
            onChanged: state.onChangeNetworkName,
            validator: state.validateNetworkName,
            label: "network_name".tr,
            readOnly: state.isDefaultNetwork,
          ),
          WidgetConstant.height20,
          Text("symbol".tr, style: context.textTheme.titleMedium),
          Text("symbol_desc".tr),
          WidgetConstant.height8,
          AppTextField(
            initialValue: state.symbol,
            onChanged: state.onChangeSymbol,
            validator: state.validateSymbol,
            label: "symbol".tr,
            readOnly: state.isDefaultNetwork,
          ),
          if (!state.isDefaultNetwork) ...[
            WidgetConstant.height20,
            Text("coin_type".tr, style: context.textTheme.titleMedium),
            LargeTextView(["slip_44_desc".tr, "coin_type_desc2".tr],
                maxLine: 1),
            WidgetConstant.height8,
            NumberTextField(
                label: "coin_type".tr,
                defaultValue: state.coinType,
                onChange: state.onChangeCoinType,
                validator: state.validateCoinType,
                max: Bip32KeyDataConst.keyIndexMaxVal,
                min: 0),
          ],
          WidgetConstant.height20,
          Text("network_explorer_address_link".tr,
              style: context.textTheme.titleMedium),
          LargeTextView(["network_evm_explorer_address_desc".tr], maxLine: 1),
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
            initialValue: state.explorerAddressLink,
            onChanged: state.onChangeExplorerTransaction,
            validator: state.validateAddressLink,
            label: "network_explorer_transaction_link".tr,
            pasteIcon: true,
          ),
          if (state.defaultProviders.isNotEmpty) ...[
            WidgetConstant.height20,
            Text("default_providers".tr, style: context.textTheme.titleMedium),
            WidgetConstant.height8,
            ...List.generate(state.defaultProviders.length, (index) {
              final provider = state.defaultProviders[index];
              return ContainerWithBorder(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.serviceName),
                  Text(provider.websiteUri),
                ],
              ));
            }),
          ],
          WidgetConstant.height20,
          Text("providers".tr, style: context.textTheme.titleMedium),
          Text("edit_or_add_evm_provider_desc".tr),
          WidgetConstant.height8,
          APPAnimatedSize(
            isActive: true,
            onDeactive: (c) => WidgetConstant.sizedBox,
            onActive: (c) => ContainerWithBorder(
                validate: state.defaultProviders.isNotEmpty ||
                    state.importedProviders.isNotEmpty,
                child: Column(
                  children: [
                    ContainerWithBorder(
                      onRemove: () {
                        state.onTapUpdateProviders();
                      },
                      onRemoveIcon: const Icon(Icons.add_box),
                      child: Text("tap_to_add_new_service_provider".tr),
                    ),
                    ...List.generate(state.importedProviders.length, (index) {
                      final provider = state.importedProviders[index];
                      return ContainerWithBorder(
                          backgroundColor: context.colors.onPrimaryContainer,
                          onRemove: () {
                            state.onRemoveProvider(provider);
                          },
                          onRemoveIcon: Icon(Icons.remove_circle,
                              color: context.colors.primaryContainer),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.protocol.value.tr,
                                  style: context.colors.primaryContainer
                                      .lableLarge(context)),
                              Text(provider.websiteUri,
                                  style: context.colors.primaryContainer
                                      .bodyMedium(context),
                                  maxLines: 2),
                            ],
                          ));
                    }),
                  ],
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.hasProvider ? state.onAddChain : null,
                  child: Text(state.isWalletNetwork
                      ? "update_network".tr
                      : "import".tr))
            ],
          )
        ],
      ),
    );
  }
}
