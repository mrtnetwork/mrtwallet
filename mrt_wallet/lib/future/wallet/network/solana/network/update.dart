import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/select_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/solana/solana.dart';

class ImportSolanaProviderView extends StatelessWidget {
  const ImportSolanaProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletSolanaNetwork network = context.getArgruments();
    return _ImportSolanaProvider(network);
  }
}

class _ImportSolanaProvider extends StatefulWidget {
  const _ImportSolanaProvider(this.network);
  final WalletSolanaNetwork network;

  @override
  State<_ImportSolanaProvider> createState() => _ImportSolanaProviderState();
}

class _ImportSolanaProviderState extends State<_ImportSolanaProvider> {
  late WalletSolanaNetwork network = widget.network.copyWith();
  late final String genesisHash = widget.network.coinParam.genesis;
  late final List<SolanaClient> providers = widget.network.coinParam.providers
      .map((e) => APIUtils.createApiClient(network, service: e) as SolanaClient)
      .toList();
  late final List<SolanaClient> defaultProviders =
      List<SolanaClient>.unmodifiable(ProvidersConst.getDefaultProvider(network)
          .map((e) =>
              APIUtils.createApiClient(network, service: e) as SolanaClient)
          .toList());
  SolanaClient? selectedProvider;
  bool hasAnyChange = false;
  bool get enableUpdateButton =>
      !hasAnyChange || (providers.isEmpty && defaultProviders.isEmpty);
  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  String rpcUrl = "";
  SolanaAPIProvider? service;

  void onSelectProvider(SolanaClient? provider) {
    if (provider == null || defaultProviders.contains(provider)) return;

    selectedProvider = provider;
    service = selectedProvider!.service.provider;
    rpcUrl = service!.httpNodeUri;
    setState(() {});
  }

  void discardChange() {
    selectedProvider = null;
    setState(() {});
  }

  void deleteProvider() {
    providers.removeWhere((element) => element == selectedProvider);
    selectedProvider = null;
    hasAnyChange = true;
    setState(() {});
  }

  void onDiscardProvider() {
    _genesisHash = null;
    verifyGenesis = false;
    setState(() {});
  }

  SolanaClient _buildSolanaRpc(
      String url, String serviceName, String websiteurl) {
    final provider = SolanaAPIProvider(
        identifier: APIUtils.getProviderIdentifier(null),
        serviceName: serviceName,
        websiteUri: websiteurl,
        httpNodeUri: url);
    return SolanaClient(
        provider: SolanaRPC(SolanaHTTPService(provider.httpNodeUri, provider)),
        network: widget.network);
  }

  void createNewRPC() {
    if (selectedProvider != null) return;
    selectedProvider = _buildSolanaRpc("", "", "");
    setState(() {});
  }

  void onPasteUri(String v) {
    uriFieldKey.currentState?.updateText(v);
  }

  void onChageUrl(String v) {
    rpcUrl = v;
  }

  String? validateRpcUrl(String? v) {
    final path = StrUtils.validateUri(v, schame: ["http", "https"]);
    if (path != null) return null;
    return "network_websocket_address_validator".tr;
  }

  void onAddProvider() async {
    if ((providers.isEmpty && defaultProviders.isEmpty) ||
        selectedProvider != null) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("updating_network".tr);
    final result = await MethodUtils.call(() async {
      final wallet = context.watch<WalletProvider>(StateConst.main);
      final services = providers.map((e) => e.service.provider).toList();
      final updatedNetwork = network.copyWith(
          coinParam: network.coinParam.copyWith(providers: services));
      return await wallet.wallet.updateImportNetwork(updatedNetwork);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.successText("network_updated_successfully".tr,
          backToIdle: false);
    }
  }

  void addProvider() async {
    if (selectedProvider == null || _genesisHash == null) return;
    if (!verifyGenesis) {
      final alert = await context.openSliverDialog(
        (p0) => DialogTextView(
          text: "network_electrum_incorrect_genesis_hash".tr,
          buttonWidget: const DialogDoubleButtonView(),
        ),
        "network_security_issue".tr,
      );
      if (alert != true) {
        discardChange();
        return;
      }
    }
    final currentProvider = providers.indexWhere((element) =>
        element.service.provider.serviceName == service?.serviceName);
    if (!currentProvider.isNegative) {
      providers[currentProvider] = selectedProvider!;
    } else {
      providers.add(selectedProvider!);
    }

    selectedProvider = null;
    _genesisHash = null;
    verifyGenesis = false;
    rpcUrl = '';
    service = null;
    hasAnyChange = true;
    setState(() {});
  }

  String? _genesisHash;
  bool verifyGenesis = false;
  void checkingRpcStatus() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    verifyGenesis = false;
    pageProgressKey.progressText("network_waiting_for_response".tr);
    final result = await MethodUtils.call(() async {
      final uniqueServiceName = StrUtils.addNumberToMakeUnique(
          providers.map((e) => e.service.provider.serviceName).toList()
            ..removeWhere((element) =>
                element == selectedProvider!.service.provider.serviceName),
          rpcUrl);
      selectedProvider = _buildSolanaRpc(rpcUrl, uniqueServiceName, rpcUrl);
      final serverBanner = await selectedProvider!.getGenesisHash();

      return serverBanner;
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      _genesisHash = result.result;
      if (_genesisHash == genesisHash) {
        verifyGenesis = true;
      }
      pageProgressKey.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: AppBar(
        title: Text("network_update_node_provider".tr),
      ),
      child: PageProgress(
        key: pageProgressKey,
        backToIdle: APPConst.twoSecoundDuration,
        child: (c) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageTitleSubtitle(
                            title: "network_security_title".tr,
                            body: LargeTextView([
                              "network_security_desc".tr,
                              "network_change_detect_desc".tr
                            ])),
                        Text("network".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                            child: Text(widget.network.coinParam.token.name)),
                        WidgetConstant.height20,
                        AnimatedSize(
                          duration: APPConst.animationDuraion,
                          child: selectedProvider == null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("default_providers".tr,
                                        style: context.textTheme.titleMedium),
                                    WidgetConstant.height8,
                                    ...List.generate(defaultProviders.length,
                                        (index) {
                                      final provider = defaultProviders[index];
                                      return ContainerWithBorder(
                                          onRemove: () {
                                            context.showAlert(
                                                "network_unbale_change_providers"
                                                    .tr);
                                          },
                                          onRemoveIcon:
                                              ProviderTrackerStatusView(
                                                  provider:
                                                      provider.service.tracker),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(provider.service.provider
                                                  .serviceName),
                                              Text(provider
                                                  .service.provider.websiteUri)
                                            ],
                                          ));
                                    }),
                                    WidgetConstant.height20,
                                    Text("providers".tr,
                                        style: context.textTheme.titleMedium),
                                    Text("edit_or_add_evm_provider_desc".tr),
                                    WidgetConstant.height8,
                                    ...List.generate(providers.length, (index) {
                                      final provider = providers[index];
                                      return ContainerWithBorder(
                                          onRemove: () {
                                            onSelectProvider(provider);
                                          },
                                          onRemoveIcon:
                                              ProviderTrackerStatusView(
                                                  provider:
                                                      provider.service.tracker),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(provider.service.provider
                                                  .serviceName),
                                              Text(provider
                                                  .service.provider.websiteUri)
                                            ],
                                          ));
                                    }),
                                    ContainerWithBorder(
                                      onRemove: createNewRPC,
                                      validate: providers.isNotEmpty,
                                      onTapWhenOnRemove: false,
                                      onRemoveIcon: const Icon(Icons.add_box),
                                      child: Text("create_new_provider".tr),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FixedElevatedButton(
                                          padding:
                                              WidgetConstant.paddingVertical20,
                                          onPressed: enableUpdateButton
                                              ? null
                                              : onAddProvider,
                                          child: Text(
                                              "network_update_network_providers"
                                                  .tr),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (providers
                                        .contains(selectedProvider)) ...[
                                      Text("edit_provider_rpc_url".tr,
                                          style: context.textTheme.titleMedium),
                                      Text("edit_or_add_evm_provider_desc".tr),
                                      WidgetConstant.height8,
                                      ContainerWithBorder(
                                          onRemove: () {},
                                          onRemoveIcon:
                                              ProviderTrackerStatusView(
                                                  provider: selectedProvider!
                                                      .service.tracker),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(selectedProvider!.service
                                                  .provider.serviceName),
                                              Text(selectedProvider!
                                                  .service.provider.websiteUri)
                                            ],
                                          )),
                                      WidgetConstant.height20,
                                    ],
                                    AnimatedSize(
                                      duration: APPConst.animationDuraion,
                                      child: _genesisHash == null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("rpc_url".tr,
                                                    style: context
                                                        .textTheme.titleMedium),
                                                Text("rpc_url_desc".tr),
                                                WidgetConstant.height8,
                                                AppTextField(
                                                  key: uriFieldKey,
                                                  initialValue: rpcUrl,
                                                  onChanged: onChageUrl,
                                                  validator: validateRpcUrl,
                                                  suffixIcon: PasteTextIcon(
                                                      onPaste: onPasteUri,
                                                      isSensitive: false),
                                                  label: "rpc_url".tr,
                                                  hint:
                                                      "https://api.mainnet.solana....",
                                                ),
                                                Padding(
                                                  padding: WidgetConstant
                                                      .paddingVertical20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      FixedElevatedButton.icon(
                                                        label: Text(
                                                            "network_verify_server_status"
                                                                .tr),
                                                        onPressed:
                                                            checkingRpcStatus,
                                                        icon: const Icon(
                                                            Icons.update),
                                                      ),
                                                      WidgetConstant.width8,
                                                      IconButton(
                                                          tooltip:
                                                              "discard_changes"
                                                                  .tr,
                                                          icon: const Icon(
                                                              Icons.cancel),
                                                          onPressed:
                                                              discardChange),
                                                      WidgetConstant.width8,
                                                      IconButton(
                                                          tooltip: "remove".tr,
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed:
                                                              deleteProvider),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                WidgetConstant.height20,
                                                Text(
                                                  "network_electrum_genesis_hash"
                                                      .tr,
                                                  style: context
                                                      .textTheme.titleMedium,
                                                ),
                                                Text("gnesis_hash_desc".tr),
                                                WidgetConstant.height8,
                                                ContainerWithBorder(
                                                    child: Text(_genesisHash!)),
                                                ErrorTextContainer(
                                                    error: !verifyGenesis
                                                        ? "network_genesis_hash_validator"
                                                            .tr
                                                        : null),
                                                Padding(
                                                  padding: WidgetConstant
                                                      .paddingVertical20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      FixedElevatedButton.icon(
                                                        label: Text(
                                                            "network_add_to_providers"
                                                                .tr),
                                                        onPressed: addProvider,
                                                        icon: const Icon(
                                                            Icons.add_box),
                                                      ),
                                                      WidgetConstant.width8,
                                                      IconButton(
                                                          tooltip:
                                                              "discard_changes"
                                                                  .tr,
                                                          icon: const Icon(
                                                              Icons.cancel),
                                                          onPressed:
                                                              onDiscardProvider),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                    )
                                  ],
                                ),
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
