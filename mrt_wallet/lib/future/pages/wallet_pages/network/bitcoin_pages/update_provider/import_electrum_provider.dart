import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/chain/defauilt_node_providers.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/types/typedef.dart';

class ImportElectrumProviderView extends StatelessWidget {
  const ImportElectrumProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppBitcoinNetwork network = context.getArgruments();
    return _ImportElectrumProvider(network);
  }
}

class _ImportElectrumProvider extends StatefulWidget {
  const _ImportElectrumProvider(this.network);
  final AppBitcoinNetwork network;

  @override
  State<_ImportElectrumProvider> createState() =>
      __ImportElectrumProviderState();
}

class __ImportElectrumProviderState extends State<_ImportElectrumProvider> {
  late AppBitcoinNetwork network = widget.network.copyWith();
  late final List<BasedBitcoinApiProvider> providers = widget
      .network.coinParam.providers
      .map((e) => ChainUtils.buildApiProvider(network, service: e)
          as BasedBitcoinApiProvider)
      .toList();
  late final List<BasedBitcoinApiProvider> defaultProviders =
      List<BasedBitcoinApiProvider>.unmodifiable(
          DefaultNodeProviders.getDefaultServices(network)
              .map((e) => ChainUtils.buildApiProvider(network, service: e)
                  as BasedBitcoinApiProvider)
              .toList());
  late final String networkGenesisHash =
      DefaultNodeProviders.getGnesisHash(network)!;
  BitcoinElectrumApiProvider? selectedProvider;

  late ProviderProtocol protocol = supportedProtocol.first;
  bool hasAnyChange = false;
  bool get enableUpdateButton =>
      !hasAnyChange || (providers.isEmpty && defaultProviders.isEmpty);

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  late List<APPEVMNetwork> evmNetworks;
  late String symbol = widget.network.coinParam.token.symbol;
  late String networkName = widget.network.coinParam.token.name;
  String rpcUrl = "";
  ElectrumServerInfos? serverInfo;
  bool validGnesis = false;
  String? chainError;
  ElectrumApiProviderService? service;

  late final List<ProviderProtocol> electrumProtocols = [
    ProviderProtocol.ssl,
    ProviderProtocol.tcp,
    ProviderProtocol.websocket
  ];
  List<ProviderProtocol> get supportedProtocol {
    if (PlatformInterface.isWeb) {
      return [ProviderProtocol.websocket];
    }
    return [
      ProviderProtocol.ssl,
      ProviderProtocol.tcp,
      ProviderProtocol.websocket
    ];
  }

  void onChangeProtocol(ProviderProtocol? selectedProtocol) {
    try {
      if (selectedProtocol == null) return;
      if (!supportedProtocol.contains(selectedProtocol)) {
        context.showAlert("network_protocol_not_supported"
            .tr
            .replaceOne(selectedProtocol.value));
        return;
      }
      protocol = selectedProtocol;
    } finally {
      setState(() {});
    }
  }

  bool canChangeProvider(BasedBitcoinApiProvider? provider) {
    return provider is BitcoinElectrumApiProvider;
  }

  void addProvider() async {
    if (selectedProvider == null || serverInfo == null) return;
    if (!validGnesis) {
      final alert = await context.openSliverDialog(
        (p0) => DialogTextView(
          text: "network_electrum_incorrect_genesis_hash".tr,
          buttomWidget: const DialogDoubleButtonView(),
        ),
        "network_security_issue".tr,
      );
      if (alert != true) {
        discardChange();
        return;
      }
    }
    final currentProvider = providers.indexWhere((element) =>
        element.serviceProvider.provider.serviceName == service?.serviceName);
    if (!currentProvider.isNegative) {
      providers[currentProvider] = selectedProvider!;
    } else {
      providers.add(selectedProvider!);
    }

    selectedProvider = null;
    serverInfo = null;
    rpcUrl = '';
    service = null;
    hasAnyChange = true;
    setState(() {});
  }

  void onSelectProvider(BasedBitcoinApiProvider? provider) {
    if (provider == null || defaultProviders.contains(provider)) return;
    if (!canChangeProvider(provider)) {
      context.showAlert("network_unbale_change_providers".tr);
      return;
    }
    selectedProvider = provider as BitcoinElectrumApiProvider;
    service = selectedProvider!.serviceProvider.provider;
    protocol = service!.protocol;
    rpcUrl = service!.endpoint;
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

  BitcoinElectrumApiProvider _buildElectrumRPC(ProviderProtocol protocol,
      String url, String serviceName, String websiteurl) {
    final service = ElectrumApiProviderService(
        serviceName: serviceName,
        websiteUri: websiteurl,
        url: url,
        protocol: protocol);
    final tracker = ApiProviderTracker(provider: service);
    return BitcoinElectrumApiProvider(
        provider: ElectrumApiProvider(
            ElectrumService.fromProvider(provider: tracker, service: service)),
        network: widget.network);
  }

  void createNewRPC() {
    if (selectedProvider != null) return;
    selectedProvider = _buildElectrumRPC(protocol, "", "", "");
    setState(() {});
  }

  String get title {
    switch (protocol) {
      case ProviderProtocol.tcp:
      case ProviderProtocol.ssl:
        return "network_tittle_tcp_ssl_url".tr.replaceOne(protocol.value);
      default:
        return "network_title_websocket_url".tr;
    }
  }

  String get hint {
    switch (protocol) {
      case ProviderProtocol.tcp:
      case ProviderProtocol.ssl:
        return "example.com:50002";
      default:
        return "wss://example.com";
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodCaller.call(() async {
      // for (final i in providers) {
      //   await i.getNetworkInfo();
      // }
    });
  }

  void onPasteUri(String v) {
    uriFieldKey.currentState?.updateText(v);
  }

  void onChageUrl(String v) {
    rpcUrl = v;
  }

  String? _validateTcpSSLUrl(String? address) {
    final path = AppStringUtility.isValidTcpAddress(address);
    if (path != null) return null;
    return "network_tcp_address_validator".tr;
  }

  String? _validateWebsocketAddress(String? address) {
    final path = AppStringUtility.validateUri(address, schame: ["wss", "ws"]);
    if (path != null) return null;
    return "network_websocket_address_validator".tr;
  }

  String? validateRpcUrl(String? v) {
    switch (protocol) {
      case ProviderProtocol.ssl:
      case ProviderProtocol.tcp:
        return _validateTcpSSLUrl(v);
      default:
        return _validateWebsocketAddress(v);
    }
  }

  void onAddChain() async {
    if ((providers.isEmpty && defaultProviders.isEmpty) ||
        selectedProvider != null) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("updating_network".tr);
    final result = await MethodCaller.call(() async {
      final wallet = context.watch<WalletProvider>(StateIdsConst.main);
      final services =
          providers.map((e) => e.serviceProvider.provider).toList();
      final updatedNetwork = network.copyWith(
          coinParam: network.coinParam.copyWith(
              providers: services,
              token: network.coinParam.token
                  .copyWith(name: networkName, symbol: symbol)));
      return await wallet.updateImportNetwork(updatedNetwork);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      pageProgressKey.successText("network_updated_successfully".tr,
          backToIdle: false);
    }
  }

  void onChangeSever() {
    serverInfo = null;
    validGnesis = false;
    setState(() {});
  }

  void onUpdate() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    pageProgressKey.progressText("network_waiting_for_response".tr);
    final result = await MethodCaller.call(() async {
      final uniqueServiceName = AppStringUtility.addNumberToMakeUnique(
          providers.map((e) => e.serviceProvider.provider.serviceName).toList()
            ..removeWhere((element) =>
                element ==
                selectedProvider!.serviceProvider.provider.serviceName),
          rpcUrl);
      selectedProvider =
          _buildElectrumRPC(protocol, rpcUrl, uniqueServiceName, rpcUrl);
      final serverBanner = await selectedProvider!.serverInfo();
      return serverBanner;
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      serverInfo = result.result;
      validGnesis = serverInfo?.genesisHash == networkGenesisHash;
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
        backToIdle: AppGlobalConst.twoSecoundDuration,
        child: () => CustomScrollView(
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
                        Text("network_electrum_genesis_hash".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(child: Text(networkGenesisHash)),
                        WidgetConstant.height20,
                        AnimatedSize(
                          duration: AppGlobalConst.animationDuraion,
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
                                                      provider.serviceProvider),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(provider.serviceProvider
                                                  .provider.serviceName),
                                              Text(provider.serviceProvider
                                                  .provider.websiteUri)
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
                                                      provider.serviceProvider),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(provider.serviceProvider
                                                  .provider.serviceName),
                                              Text(provider.serviceProvider
                                                  .provider.websiteUri)
                                            ],
                                          ));
                                    }),
                                    ContainerWithBorder(
                                      onRemove: createNewRPC,
                                      validate: providers.isNotEmpty,
                                      onTapWhenOnRemove: false,
                                      onRemoveIcon: const Icon(Icons.add_box),
                                      child: AppDropDownBottom(
                                        key: UniqueKey(),
                                        items: {
                                          for (final i in electrumProtocols)
                                            i: Text(i.value)
                                        },
                                        label: "protocol".tr,
                                        value: protocol,
                                        onChanged: onChangeProtocol,
                                      ),
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
                                              : onAddChain,
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
                                                      .serviceProvider),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(selectedProvider!
                                                  .serviceProvider
                                                  .provider
                                                  .serviceName),
                                              Text(selectedProvider!
                                                  .serviceProvider
                                                  .provider
                                                  .websiteUri)
                                            ],
                                          )),
                                      WidgetConstant.height20,
                                    ],
                                    AnimatedSize(
                                      duration: AppGlobalConst.animationDuraion,
                                      child: serverInfo == null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "network_electrum_server_url"
                                                        .tr,
                                                    style: context
                                                        .textTheme.titleMedium),
                                                Text(title),
                                                WidgetConstant.height8,
                                                AppTextField(
                                                  key: uriFieldKey,
                                                  initialValue: rpcUrl,
                                                  onChanged: onChageUrl,
                                                  validator: validateRpcUrl,
                                                  suffixIcon: PasteTextIcon(
                                                      onPaste: onPasteUri),
                                                  label:
                                                      "network_electrum_server_url"
                                                          .tr,
                                                  hint: hint,
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
                                                        onPressed: onUpdate,
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
                                          : _ElectrumServerInfosView(
                                              info: serverInfo!,
                                              onDiscard: onChangeSever,
                                              onUpdate: addProvider,
                                              validGenesis: validGnesis,
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

class _ElectrumServerInfosView extends StatelessWidget {
  const _ElectrumServerInfosView({
    required this.info,
    required this.onDiscard,
    required this.onUpdate,
    required this.validGenesis,
  });
  final ElectrumServerInfos info;
  final DynamicVoid onDiscard;
  final DynamicVoid onUpdate;
  final bool validGenesis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("network_server_banner".tr, style: context.textTheme.titleMedium),
        Text("network_server_banner_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(child: Text(info.banner)),
        WidgetConstant.height20,
        Text("network_server_features".tr,
            style: context.textTheme.titleMedium),
        Text("network_server_features_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: !info.hasValidFeature
                ? Text(info.features.toString())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(info.features.length, (index) {
                      final String key = info.features.keys.elementAt(index);
                      final String? val = info.features[key]?.toString();
                      if (val == null) return WidgetConstant.sizedBox;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: context.textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                    text: key,
                                    style: context.textTheme.labelLarge),
                                const TextSpan(text: ": "),
                                TextSpan(text: val)
                              ],
                            ),
                          ),
                          WidgetConstant.height8,
                        ],
                      );
                    }),
                  )),
        WidgetConstant.height20,
        Text("network_header".tr, style: context.textTheme.titleMedium),
        Text("network_block_header_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(info.header.length, (index) {
            final String key = info.header.keys.elementAt(index);
            final String val = info.header[key]!.toString();
            return RichText(
              text: TextSpan(
                style: context.textTheme.bodyMedium,
                children: [
                  TextSpan(text: key),
                  const TextSpan(text: ": "),
                  TextSpan(text: val)
                ],
              ),
            );
          }),
        )),
        ErrorTextContainer(
            error: !validGenesis ? "network_genesis_hash_validator".tr : null),
        Padding(
          padding: WidgetConstant.paddingVertical20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton.icon(
                label: Text("network_add_to_providers".tr),
                onPressed: onUpdate,
                icon: const Icon(Icons.add_box),
              ),
              WidgetConstant.width8,
              IconButton(
                  tooltip: "discard_changes".tr,
                  icon: const Icon(Icons.cancel),
                  onPressed: onDiscard),
            ],
          ),
        )
      ],
    );
  }
}
