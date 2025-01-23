import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

mixin UpdateNetworkProviderState<
        W extends StatefulWidget,
        PROVIDER extends APIProvider,
        NETWORKADDRESS,
        ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
        CL extends NetworkClient<ADDRESS, PROVIDER>,
        T extends TokenCore,
        N extends NFTCore,
        CHAIN extends APPCHAINACCOUNTCLIENT<ADDRESS, PROVIDER, CL, T, N>>
    on SafeState<W>, ProgressMixin<W> {
  bool useAuthenticated = false;
  ProviderAuthType auth = ProviderAuthType.header;
  List<ProviderAuthType> supportedAuth = [];
  late final List<APIProviderServiceInfo> services;
  late APIProviderServiceInfo service;
  String? get serviceDescription => null;

  void onChangeAuthMode(ProviderAuthType? auth) {
    this.auth = auth ?? this.auth;
    updateState();
  }

  void onChangeService(APIProviderServiceInfo? service) {
    if (service == null || !services.contains(service)) return;
    this.service = service;
    updateState();
  }

  bool inAddProvider = false;
  CHAIN get chain;
  WalletNetwork get network => chain.network;
  late final List<PROVIDER> providers;
  late final List<PROVIDER> defaultProviders;
  List<ServiceProtocol> get supportedProtocol;
  late ServiceProtocol protocol;
  Future<PROVIDER> validate(PROVIDER provider);
  @override
  void onInitOnce() {
    super.onInitOnce();
    MethodUtils.after(() async {
      providers = List.from(chain.network.coinParam.providers);
      defaultProviders =
          ProvidersConst.getDefaultProvider<PROVIDER>(chain.network);
      services = ProvidersConst.networkSupportServices(chain.network);
      service = services.first;
      setProtocol(supportedProtocol.first);
      progressKey.backToIdle();
    });
  }

  PROVIDER createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth});

  ProviderAuthenticated? createAuth() {
    if (enableAuthMode && useAuthenticated) {
      return BasicProviderAuthenticated(
          type: auth, key: authKey, value: authValue);
    }
    return null;
  }

  bool hasAnyChange = false;
  String rpcUrl = "";
  bool enableAuthMode = false;
  bool get enableUpdateButton =>
      !hasAnyChange || (providers.isEmpty && defaultProviders.isEmpty);
  void onPasteUri(String v) {
    uriFieldKey.currentState?.updateText(v);
  }

  void onChageUrl(String v) {
    rpcUrl = v;
  }

  void onChangeAuthenticated(bool? v) {
    useAuthenticated = !useAuthenticated;
    updateState();
  }

  String authKey = "";
  String authValue = "";

  void onChangeKey(String v) {
    authKey = v;
  }

  void onChangeValue(String v) {
    authValue = v;
  }

  String? validateKey(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_key_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  String? validateValue(String? v) {
    if (v?.trim().isEmpty ?? true) {
      return "authenticated_value_validator".tr;
    }
    if (v!.length > APPConst.maximumHeaderValue) {
      return "value_is_to_large".tr;
    }
    return null;
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<AppTextFieldState> uriFieldKey = GlobalKey();
  void addProvider(PROVIDER provider) {
    providers.add(provider);
    inAddProvider = false;
    rpcUrl = '';
    hasAnyChange = true;
    updateState();
  }

  void setProtocol(ServiceProtocol selectedProtocol) {
    protocol = selectedProtocol;
    if (protocol == ServiceProtocol.http) {
      supportedAuth = [ProviderAuthType.query, ProviderAuthType.header];
    } else if (protocol == ServiceProtocol.websocket) {
      supportedAuth = [ProviderAuthType.query];
      auth = ProviderAuthType.query;
    } else {
      supportedAuth = [];
    }
    enableAuthMode = supportedAuth.isNotEmpty;
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
      setProtocol(selectedProtocol);
    } finally {
      updateState();
    }
  }

  bool canChangeProvider(PROVIDER provider) {
    return !provider.isDefaultProvider;
  }

  String? _validateTcpSSLUrl(String? address) {
    final path = StrUtils.isValidTcpAddress(address);
    if (path != null) return null;
    return "network_tcp_address_validator".tr;
  }

  String? validateWebsocketAddress(String? address) {
    final path = StrUtils.validateUri(address, schame: ["wss", "ws"]);
    if (path != null) return null;
    return "network_websocket_address_validator".tr;
  }

  String? validateHttpAddress(String? address) {
    final path = StrUtils.validateUri(address, schame: ["http", "https"]);
    if (path != null) return null;
    return "rpc_url_validator".tr;
  }

  String? validateRpcUrl(String? v) {
    switch (protocol) {
      case ServiceProtocol.http:
        return validateHttpAddress(v);
      case ServiceProtocol.ssl:
      case ServiceProtocol.tcp:
        return _validateTcpSSLUrl(v);
      default:
        return validateWebsocketAddress(v);
    }
  }

  void createNewProvider() {
    inAddProvider = true;
    updateState();
  }

  String get protocolTitle {
    switch (protocol) {
      case ServiceProtocol.http:
        return "network_title_http_url".tr;
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "network_tittle_tcp_ssl_url".tr.replaceOne(protocol.value);
      default:
        return "network_title_websocket_url".tr;
    }
  }

  String get protocolHint {
    switch (protocol) {
      case ServiceProtocol.http:
        return "https://example.com";
      case ServiceProtocol.tcp:
      case ServiceProtocol.ssl:
        return "example.com:50002";
      default:
        return "wss://example.com";
    }
  }

  void deleteProvider(PROVIDER? provider) {
    if (provider == null) return;
    providers
        .removeWhere((element) => element.identifier == provider.identifier);
    hasAnyChange = true;
    updateState();
  }

  void importProvider() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    progressKey.progressText("network_waiting_for_response".tr);
    final result = await MethodUtils.call(() async {
      final auth = createAuth();
      final provider =
          createProvider(url: rpcUrl, service: service, auth: auth);
      return validate(provider);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr,
          showBackButton: true, backToIdle: false);
      return;
    }
    addProvider(result.result);
    progressKey.success();
  }

  void updateNetworkProviders() async {
    progressKey.progressText("updating_network".tr);
    final result = await MethodUtils.call(() async {
      final wallet = context.watch<WalletProvider>(StateConst.main);
      final services = providers.map((e) => e).toList();
      final param = network.coinParam;
      final updatedNetwork = network.copyWith(
          coinParam: param.updateParams(
              updateProviders: services,
              addressExplorer: param.addressExplorer,
              transactionExplorer: param.transactionExplorer));
      return await wallet.wallet.updateImportNetwork(updatedNetwork);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText(
        "network_updated_successfully".tr,
      );
    }
  }

  void onBackButton() {
    inAddProvider = false;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPageView(
      appBar: AppBar(title: Text("network_update_node_provider".tr)),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          onBackButton();
        },
        canPop: !inAddProvider,
        child: PageProgress(
          key: progressKey,
          initialStatus: StreamWidgetStatus.progress,
          backToIdle: APPConst.twoSecoundDuration,
          child: (c) => UnfocusableChild(
            child: CustomScrollView(
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
                                child: Text(
                              network.coinParam.token.name,
                              style: context.colors.onPrimaryContainer
                                  .bodyMedium(context),
                            )),
                            WidgetConstant.height20,
                            AnimatedSize(
                                duration: APPConst.animationDuraion,
                                child: ConditionalWidgets(
                                    enable: !inAddProvider,
                                    widgets: {
                                      true: (context) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("default_providers".tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              WidgetConstant.height8,
                                              APPExpansionListTile(
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "default_providers".tr,
                                                      style: context.colors
                                                          .onPrimaryContainer
                                                          .bodyMedium(context),
                                                    ),
                                                    Text(
                                                      "network_unbale_change_providers"
                                                          .tr,
                                                      style: context.colors
                                                          .onPrimaryContainer
                                                          .bodySmall(context),
                                                    )
                                                  ],
                                                ),
                                                children: List.generate(
                                                    defaultProviders.length,
                                                    (index) {
                                                  final provider =
                                                      defaultProviders[index];
                                                  return ContainerWithBorder(
                                                      backgroundColor: context
                                                          .colors
                                                          .onPrimaryContainer,
                                                      child: CopyableTextWidget(
                                                          text:
                                                              provider.callUrl,
                                                          color: context.colors
                                                              .primaryContainer));
                                                }),
                                              ),
                                              if (providers.isNotEmpty) ...[
                                                WidgetConstant.height20,
                                                Text("providers".tr,
                                                    style: context
                                                        .textTheme.titleMedium),
                                                Text(
                                                    "tap_to_add_new_service_provider"
                                                        .tr),
                                                WidgetConstant.height8,
                                                ...List.generate(
                                                    providers.length, (index) {
                                                  final provider =
                                                      providers[index];
                                                  return ContainerWithBorder(
                                                      onRemove: () {},
                                                      enableTap: false,
                                                      onRemoveWidget:
                                                          IconButton(
                                                              onPressed: () {
                                                                deleteProvider(
                                                                    provider);
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .remove_circle,
                                                                  color: context
                                                                      .colors
                                                                      .onPrimaryContainer)),
                                                      child: CopyableTextWidget(
                                                          text:
                                                              provider.callUrl,
                                                          widget: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  provider
                                                                      .protocol
                                                                      .value,
                                                                  style: context
                                                                      .onPrimaryTextTheme
                                                                      .labelLarge),
                                                              Text(
                                                                  provider
                                                                      .callUrl,
                                                                  style: context
                                                                      .onPrimaryTextTheme
                                                                      .bodyMedium),
                                                            ],
                                                          ),
                                                          color: context.colors
                                                              .onPrimaryContainer));
                                                }),
                                              ],
                                              WidgetConstant.height20,
                                              Text("service_provider".tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              if (serviceDescription != null)
                                                Text(serviceDescription!),
                                              WidgetConstant.height8,
                                              ContainerWithBorder(
                                                enableTap: false,
                                                onRemove: service.url == null
                                                    ? null
                                                    : () {
                                                        UriUtils.lunch(
                                                            service.url);
                                                      },
                                                onRemoveIcon: ToolTipView(
                                                  key: ValueKey(service),
                                                  message: service.url,
                                                  child: Icon(
                                                      Icons.open_in_new_rounded,
                                                      color: context
                                                          .onPrimaryContainer),
                                                ),
                                                child: AppDropDownBottom(
                                                    key: ValueKey(service),
                                                    border: InputBorder.none,
                                                    isExpanded: true,
                                                    fillColor: context
                                                        .colors.transparent,
                                                    items: {
                                                      for (final i in services)
                                                        i: Text(i.name,
                                                            style: context
                                                                .onPrimaryTextTheme
                                                                .bodyMedium)
                                                    },
                                                    itemBuilder: {
                                                      for (final i in services)
                                                        i: Text(i.name)
                                                    },
                                                    labelStyle: context.colors
                                                        .onPrimaryContainer
                                                        .lableLarge(context),
                                                    value: service,
                                                    onChanged: onChangeService),
                                              ),
                                              WidgetConstant.height20,
                                              Text("protocol".tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              WidgetConstant.height8,
                                              ContainerWithBorder(
                                                onRemove: createNewProvider,
                                                enableTap: false,
                                                onRemoveIcon: Icon(
                                                    Icons.add_box,
                                                    color: context
                                                        .onPrimaryContainer),
                                                child: AppDropDownBottom(
                                                  key: ValueKey(protocol),
                                                  border: InputBorder.none,
                                                  fillColor: context
                                                      .colors.transparent,
                                                  items: {
                                                    for (final i
                                                        in supportedProtocol)
                                                      i: Text(
                                                        i.value,
                                                        style: context.colors
                                                            .onPrimaryContainer
                                                            .bodyMedium(
                                                                context),
                                                      )
                                                  },
                                                  itemBuilder: {
                                                    for (final i
                                                        in supportedProtocol)
                                                      i: Text(i.value)
                                                  },
                                                  labelStyle: context
                                                      .colors.onPrimaryContainer
                                                      .lableLarge(context),
                                                  value: protocol,
                                                  onChanged: onChangeProtocol,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FixedElevatedButton(
                                                    padding: WidgetConstant
                                                        .paddingVertical20,
                                                    onPressed: enableUpdateButton
                                                        ? null
                                                        : updateNetworkProviders,
                                                    child: Text(
                                                        "network_update_network_providers"
                                                            .tr),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                      false: (cotext) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("api_url".tr,
                                                  style: context
                                                      .textTheme.titleMedium),
                                              Text(protocolTitle),
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
                                                label: "api_url".tr,
                                                hint: protocolHint,
                                              ),
                                              ProviderAuthView(
                                                  enableAuthMode:
                                                      enableAuthMode,
                                                  useAuthenticated:
                                                      useAuthenticated,
                                                  onChangeAuthenticated:
                                                      onChangeAuthenticated,
                                                  onChangeAuthMode:
                                                      onChangeAuthMode,
                                                  auth: auth,
                                                  authKey: authKey,
                                                  authValue: authValue,
                                                  onChangeKey: onChangeKey,
                                                  validateKey: validateKey,
                                                  onChangeValue: onChangeValue,
                                                  validateValue: validateValue,
                                                  supportedAuths:
                                                      supportedAuth),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  FixedElevatedButton.icon(
                                                    padding: WidgetConstant
                                                        .paddingVertical40,
                                                    label: Text(
                                                        "network_verify_server_status"
                                                            .tr),
                                                    onPressed: importProvider,
                                                    icon: const Icon(
                                                        Icons.update),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                    }))
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
typedef ONCHANGEAUTHMODE = void Function(ProviderAuthType? auth);

class ProviderAuthView extends StatelessWidget {
  const ProviderAuthView(
      {super.key,
      required this.enableAuthMode,
      required this.useAuthenticated,
      required this.onChangeAuthenticated,
      required this.onChangeAuthMode,
      required this.auth,
      required this.authKey,
      required this.authValue,
      required this.onChangeKey,
      required this.validateKey,
      required this.onChangeValue,
      required this.validateValue,
      required this.supportedAuths});
  final bool enableAuthMode;
  final bool useAuthenticated;
  final NullBoolVoid? onChangeAuthenticated;
  final ONCHANGEAUTHMODE onChangeAuthMode;
  final ProviderAuthType auth;
  final String authKey;
  final String authValue;
  final StringVoid? onChangeKey;
  final NullStringString? validateKey;
  final StringVoid? onChangeValue;
  final NullStringString? validateValue;
  final List<ProviderAuthType> supportedAuths;

  @override
  Widget build(BuildContext context) {
    return ConditionalWidgets(enable: enableAuthMode, widgets: {
      true: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("authenticated".tr),
              subtitle: Text("add_provider_authenticated".tr),
              value: useAuthenticated,
              onChanged: onChangeAuthenticated,
            ),
            APPAnimatedSize(
                isActive: useAuthenticated,
                onActive: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height8,
                        AppDropDownBottom(
                          items: {
                            for (final i in supportedAuths)
                              i: Text(i.name.camelCase)
                          },
                          onChanged: onChangeAuthMode,
                          value: auth,
                        ),
                        WidgetConstant.height20,
                        AppTextField(
                          label: "authenticated_key".tr,
                          pasteIcon: true,
                          initialValue: authKey,
                          hint: "example_value".tr.replaceOne(auth.isHeader
                              ? APPConst.exampleAuthenticatedHeader
                              : APPConst.exampleAuthenticatedQuery),
                          onChanged: onChangeKey,
                          validator: validateKey,
                        ),
                        AppTextField(
                            pasteIcon: true,
                            label: "authenticated_value".tr,
                            initialValue: authValue,
                            hint: "example_value".tr.replaceOne(auth.isHeader
                                ? APPConst.exampleAuthenticatedHeaderValue
                                : APPConst.exampleBase58),
                            onChanged: onChangeValue,
                            validator: validateValue),
                      ],
                    ),
                onDeactive: (c) => WidgetConstant.sizedBox),
          ],
        );
      }
    });
  }
}
