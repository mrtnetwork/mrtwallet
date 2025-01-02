import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';

class UpdateTronProvider extends StatelessWidget {
  const UpdateTronProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<TronChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateTronProvider(chain));
  }
}

class _UpdateTronProvider extends StatefulWidget {
  const _UpdateTronProvider(this.account);
  final TronChain account;

  @override
  State<_UpdateTronProvider> createState() => _UpdateTronProviderState();
}

class _UpdateTronProviderState extends State<_UpdateTronProvider>
    with
        SafeState<_UpdateTronProvider>,
        ProgressMixin<_UpdateTronProvider>,
        UpdateNetworkProviderState<
            _UpdateTronProvider,
            TronAPIProvider,
            TronAddress,
            ITronAddress,
            TronClient,
            TokenCore,
            NFTCore,
            TronChain> {
  @override
  TronChain get chain => widget.account;
  final GlobalKey<AppTextFieldState> jsonFeildKey = GlobalKey();
  String jsonRpcUrl = '';
  void onChageJsonRpcUrl(String v) {
    jsonRpcUrl = v;
  }

  void onPasteJsonRpcUri(String v) {
    jsonFeildKey.currentState?.updateText(v);
  }

  ProviderAuthType jsonRpcAuth = ProviderAuthType.header;
  void onJsonRpcChangeAuthMode(ProviderAuthType? auth) {
    jsonRpcAuth = auth ?? jsonRpcAuth;
    updateState();
  }

  void onJsonRpcChangeAuthenticated(bool? v) {
    jsonRpcUseAuthenticated = !jsonRpcUseAuthenticated;
    updateState();
  }

  bool jsonRpcUseAuthenticated = false;
  String jsonRpcAuthKey = "";
  String jsonRpcAuthValue = "";

  void onJsonRpcChangeKey(String v) {
    jsonRpcAuthKey = v;
  }

  void onJsonRpcChangeValue(String v) {
    jsonRpcAuthValue = v;
  }

  String? validateHttpWss(String? address) {
    final path =
        StrUtils.validateUri(address, schame: ["http", "https", "wss", "ws"]);
    if (path != null) return null;
    return "invalid_url".tr;
  }

  @override
  TronAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return TronAPIProvider(
        httpNodeUri: url,
        auth: auth,
        identifier: APIUtils.getProviderIdentifier(),
        solidityProvider: EthereumAPIProvider(
            uri: jsonRpcUrl,
            identifier: APIUtils.getProviderIdentifier(),
            auth: jsonRpcUseAuthenticated
                ? BasicProviderAuthenticated(
                    type: jsonRpcAuth,
                    key: jsonRpcAuthKey,
                    value: jsonRpcAuthValue)
                : null));
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    supportedProtocol = [ServiceProtocol.http];
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<TronAPIProvider> validate(TronAPIProvider provider) async {
    final client = APIUtils.buildTronProvider(
        httpProviderService: provider, network: network.toNetwork());
    bool init = await client.checkGenesis();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    init = await client.checkSolidityChainId();
    if (!init) {
      throw WalletException("network_incorrect_chain_id");
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
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
                                                        text: provider.callUrl,
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
                                              ...List.generate(providers.length,
                                                  (index) {
                                                final provider =
                                                    providers[index];
                                                return ContainerWithBorder(
                                                    onRemove: () {},
                                                    enableTap: false,
                                                    onRemoveWidget: IconButton(
                                                        onPressed: () {
                                                          deleteProvider(
                                                              provider);
                                                        },
                                                        icon: Icon(
                                                            Icons.remove_circle,
                                                            color: context
                                                                .colors
                                                                .onPrimaryContainer)),
                                                    child: CopyableTextWidget(
                                                        text: provider.callUrl,
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
                                                  labelStyle: context
                                                      .colors.onPrimaryContainer
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
                                              onRemoveIcon: Icon(Icons.add_box,
                                                  color: context
                                                      .onPrimaryContainer),
                                              child: AppDropDownBottom(
                                                key: ValueKey(protocol),
                                                border: InputBorder.none,
                                                fillColor:
                                                    context.colors.transparent,
                                                items: {
                                                  for (final i
                                                      in supportedProtocol)
                                                    i: Text(
                                                      i.value,
                                                      style: context.colors
                                                          .onPrimaryContainer
                                                          .bodyMedium(context),
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
                                            Text("http_api_url".tr,
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
                                                enableAuthMode: enableAuthMode,
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
                                                supportedAuths: supportedAuth),
                                            WidgetConstant.height20,
                                            Text("json_rpc_solidity_url".tr,
                                                style: context
                                                    .textTheme.titleMedium),
                                            Text("network_title_http_wss_url"
                                                .tr),
                                            WidgetConstant.height8,
                                            AppTextField(
                                              key: jsonFeildKey,
                                              initialValue: jsonRpcUrl,
                                              onChanged: onChageJsonRpcUrl,
                                              validator: validateHttpWss,
                                              suffixIcon: PasteTextIcon(
                                                  onPaste: onPasteJsonRpcUri,
                                                  isSensitive: false),
                                              label: "api_url".tr,
                                              hint: protocolHint,
                                            ),
                                            ProviderAuthView(
                                                enableAuthMode: enableAuthMode,
                                                useAuthenticated:
                                                    jsonRpcUseAuthenticated,
                                                onChangeAuthenticated:
                                                    onJsonRpcChangeAuthenticated,
                                                onChangeAuthMode:
                                                    onJsonRpcChangeAuthMode,
                                                auth: jsonRpcAuth,
                                                authKey: jsonRpcAuthKey,
                                                authValue: jsonRpcAuthValue,
                                                onChangeKey: onJsonRpcChangeKey,
                                                validateKey: validateKey,
                                                onChangeValue:
                                                    onJsonRpcChangeValue,
                                                validateValue: validateValue,
                                                supportedAuths: supportedAuth),
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
                                                  icon:
                                                      const Icon(Icons.update),
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
    );
  }
}
