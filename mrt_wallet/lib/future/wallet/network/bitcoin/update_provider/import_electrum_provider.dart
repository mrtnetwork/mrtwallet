import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/select_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ImportElectrumProviderView extends StatelessWidget {
  const ImportElectrumProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletBitcoinNetwork network = context.getArgruments();
    return _ImportElectrumProvider(network);
  }
}

class _ImportElectrumProvider extends StatefulWidget {
  const _ImportElectrumProvider(this.network);
  final WalletBitcoinNetwork network;

  @override
  State<_ImportElectrumProvider> createState() =>
      __ImportElectrumProviderState();
}

class __ImportElectrumProviderState extends State<_ImportElectrumProvider> {
  late WalletBitcoinNetwork network = widget.network.copyWith();
  late final List<BitcoinClient> providers = widget.network.coinParam.providers
      .map(
          (e) => APIUtils.createApiClient(network, service: e) as BitcoinClient)
      .toList();
  late final List<BitcoinClient> defaultProviders =
      List<BitcoinClient>.unmodifiable(
          ProvidersConst.getDefaultProvider(network)
              .map((e) => APIUtils.createApiClient(network, service: e)
                  as BitcoinClient)
              .toList());
  late final String networkGenesisHash = widget.network.coinParam.genesis;
  BitcoinElectrumClient? selectedProvider;

  late ServiceProtocol protocol = supportedProtocol.first;
  bool hasAnyChange = false;
  bool get enableUpdateButton =>
      !hasAnyChange || (providers.isEmpty && defaultProviders.isEmpty);

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  late List<WalletEthereumNetwork> evmNetworks;

  String rpcUrl = "";
  ElectrumServerInfos? serverInfo;
  bool validGnesis = false;
  String? chainError;
  ElectrumAPIProvider? service;

  late final List<ServiceProtocol> electrumProtocols = [
    ServiceProtocol.ssl,
    ServiceProtocol.tcp,
    ServiceProtocol.websocket
  ];
  List<ServiceProtocol> get supportedProtocol {
    if (PlatformInterface.isWeb) {
      return [ServiceProtocol.websocket];
    }
    return [
      ServiceProtocol.ssl,
      ServiceProtocol.tcp,
      ServiceProtocol.websocket
    ];
  }

  void onChangeProtocol(ServiceProtocol? selectedProtocol) {
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

  bool canChangeProvider(BitcoinClient? provider) {
    return provider is BitcoinElectrumClient;
  }

  void addProvider() async {
    if (selectedProvider == null || serverInfo == null) return;
    if (!validGnesis) {
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
    serverInfo = null;
    rpcUrl = '';
    service = null;
    hasAnyChange = true;
    setState(() {});
  }

  void onSelectProvider(BitcoinClient? provider) {
    if (provider == null || defaultProviders.contains(provider)) return;
    if (!canChangeProvider(provider)) {
      context.showAlert("network_unbale_change_providers".tr);
      return;
    }
    selectedProvider = provider as BitcoinElectrumClient;
    service = selectedProvider!.service.provider;
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

  BitcoinElectrumClient _buildElectrumRPC(ServiceProtocol protocol, String url,
      String serviceName, String websiteurl) {
    final service = ElectrumAPIProvider(
        serviceName: serviceName,
        websiteUri: websiteurl,
        url: url,
        protocol: protocol,
        identifier: APIUtils.getProviderIdentifier(null));
    return BitcoinElectrumClient(
        provider: ElectrumApiProvider(
            ElectrumService.fromProvider(provider: service, service: service)),
        network: widget.network);
  }

  void createNewRPC() {
    if (selectedProvider != null) return;
    selectedProvider = _buildElectrumRPC(protocol, "", "", "");
    setState(() {});
  }

  String get title {
    switch (protocol) {
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "network_tittle_tcp_ssl_url".tr.replaceOne(protocol.value);
      default:
        return "network_title_websocket_url".tr;
    }
  }

  String get hint {
    switch (protocol) {
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "example.com:50002";
      default:
        return "wss://example.com";
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.call(() async {
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
    final path = StrUtils.isValidTcpAddress(address);
    if (path != null) return null;
    return "network_tcp_address_validator".tr;
  }

  String? _validateWebsocketAddress(String? address) {
    final path = StrUtils.validateUri(address, schame: ["wss", "ws"]);
    if (path != null) return null;
    return "network_websocket_address_validator".tr;
  }

  String? validateRpcUrl(String? v) {
    switch (protocol) {
      case ServiceProtocol.ssl:
      case ServiceProtocol.tcp:
        return _validateTcpSSLUrl(v);
      default:
        return _validateWebsocketAddress(v);
    }
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

  void onChangeSever() {
    serverInfo = null;
    validGnesis = false;
    setState(() {});
  }

  void onUpdate() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    pageProgressKey.progressText("network_waiting_for_response".tr);
    final result = await MethodUtils.call(() async {
      final uniqueServiceName = StrUtils.addNumberToMakeUnique(
          providers.map((e) => e.service.provider.serviceName).toList()
            ..removeWhere((element) =>
                element == selectedProvider!.service.provider.serviceName),
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
                        Text("network_electrum_genesis_hash".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(child: Text(networkGenesisHash)),
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
                                                    onPaste: onPasteUri,
                                                    isSensitive: false,
                                                  ),
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
