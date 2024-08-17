import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class UpdateEthereumProvider extends StatelessWidget {
  const UpdateEthereumProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final (BigInt, List<EthereumAPIProvider> provides) args =
        context.getArgruments();
    return _UpdateEthereumProvider(args.$1, args.$2);
  }
}

class _UpdateEthereumProvider extends StatefulWidget {
  const _UpdateEthereumProvider(this.chainId, this.providers);
  final List<EthereumAPIProvider> providers;
  final BigInt chainId;

  @override
  State<_UpdateEthereumProvider> createState() =>
      __UpdateEthereumNetworkState();
}

class __UpdateEthereumNetworkState extends State<_UpdateEthereumProvider>
    with SafeState {
  late final BigInt chainId = widget.chainId;
  final Set<String> existsProviders = {};
  EthereumAPIProvider? provider;
  ProviderAuthType auth = ProviderAuthType.header;
  void onChangeAuthMode(ProviderAuthType? auth) {
    this.auth = auth ?? this.auth;
    updateState();
  }

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<PageProgressState> pageProgressKey = GlobalKey();

  late List<EthereumAPIProvider> providers = List.from(widget.providers);

  late bool addNewProviders = providers.isEmpty;

  late String rpcUrl = provider?.callUrl ?? "";

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

  bool useAuthenticated = false;

  void onChangeAuthenticated(bool? v) {
    useAuthenticated = !useAuthenticated;
    updateState();
  }

  void onChageUrl(String v) {
    rpcUrl = v;
  }

  bool useInWeb3 = true;
  void onChangeUseInWeb3(bool? web3) {
    useInWeb3 = !useInWeb3;
    updateState();
  }

  void reset() {
    rpcUrl = "";
    authKey = "";
    authValue = "";
    auth = ProviderAuthType.header;
    useAuthenticated = false;
    useInWeb3 = true;
    addNewProviders = false;
    provider = null;
  }

  String? validateRpcUrl(String? v) {
    final path =
        StrUtils.validateUri(v, schame: ['http', 'https', 'wss', 'ws']);
    if (path == null) return "rpc_url_validator".tr;
    final exists = existsProviders.contains(v);
    if (exists) {
      return "rpc_url_already_exists".tr;
    }

    return null;
  }

  void onUpdate() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    pageProgressKey.progressText("checking_rpc_network_info".tr);
    EthereumClient? client;
    final result = await MethodUtils.call(() async {
      final WalletProvider wallet =
          context.watch<WalletProvider>(StateConst.main);
      final ethNetwork = wallet.wallet.networks<WalletEthereumNetwork>();
      final uri = Uri.parse(rpcUrl.trim()).normalizePath();
      ProviderAuth? auth;
      if (useAuthenticated) {
        auth = ProviderAuth(type: this.auth, key: authKey, value: authValue);
      }
      final serviceProvider = EthereumAPIProvider(
          serviceName: uri.host,
          identifier:
              provider?.identifier ?? APIUtils.getProviderIdentifier(null),
          websiteUri: StrUtils.removeSchame(uri.host),
          uri: uri.toString(),
          auth: auth,
          allowInWeb3: useInWeb3);
      client =
          APIUtils.buildEthereumProvider(serviceProvider, ethNetwork.first);
      final info = await client!.getNetworkInfo();
      if (info.$1 != widget.chainId) {
        throw WalletException("invalid_chain_id");
      }
      if (provider != null) {
        final index = providers.indexOf(provider!);
        if (index >= 0) {
          providers[index] = serviceProvider;
          return;
        }
      }
      providers.add(serviceProvider);
    });
    if (result.hasError) {
      pageProgressKey.errorText(result.error!.tr);
    } else {
      setState(() {});
      pageProgressKey.successText("network_providers_has_been_updated".tr,
          backToIdle: true);
      reset();
    }
    client?.service.disposeService();
  }

  void addNewProvider() {
    provider = null;
    addNewProviders = true;
    updateState();
  }

  void onBackButton(bool v, _) {
    if (providers.isNotEmpty) {
      addNewProviders = false;
      updateState();
    }
  }

  void removeProvider(EthereumAPIProvider provider) {
    providers.remove(provider);

    updateState();
  }

  void editProver(EthereumAPIProvider provider) {
    this.provider = provider;
    rpcUrl = provider.callUrl;
    addNewProviders = true;
    updateState();
  }

  void updateProviders() {
    context.pop(providers);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffolPageView(
      appBar: AppBar(title: Text("update_network".tr)),
      child: UnfocusableChild(
        child: Form(
          key: formKey,
          canPop: (addNewProviders && providers.isEmpty) || !addNewProviders,
          onPopInvokedWithResult: onBackButton,
          child: PageProgress(
            key: pageProgressKey,
            backToIdle: APPConst.oneSecoundDuration,
            child: (c) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: WidgetConstant.padding20,
                  sliver: SliverConstraintsBoxView(
                    sliver: APPSliverAnimatedSwitcher(
                        enable: addNewProviders,
                        widgets: {
                          true: (c) => _ImportProviderWidget(this),
                          false: (c) => _ShowProvidersWidget(this)
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowProvidersWidget extends StatelessWidget {
  const _ShowProvidersWidget(this.state, {Key? key}) : super(key: key);
  final __UpdateEthereumNetworkState state;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("providers".tr, style: context.textTheme.titleMedium),
            Text("update_provider_desc".tr),
            WidgetConstant.height8,
          ],
        ),
      ),
      SliverList.builder(
        itemBuilder: (context, index) {
          final provider = state.providers[index];
          return ContainerWithBorder(
              iconAlginment: CrossAxisAlignment.start,
              onRemove: () {},
              onRemoveWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => state.editProver(provider),
                      icon: Icon(Icons.edit,
                          color: context.colors.onPrimaryContainer)),
                  IconButton(
                      onPressed: () => state.removeProvider(provider),
                      icon: Icon(
                        Icons.remove,
                        color: context.colors.onPrimaryContainer,
                      )),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.protocol.value.tr,
                      style: context.colors.onPrimaryContainer
                          .lableLarge(context)),
                  Text(provider.websiteUri,
                      style:
                          context.colors.onPrimaryContainer.bodyMedium(context),
                      maxLines: 2),
                ],
              ));
        },
        itemCount: state.providers.length,
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            ContainerWithBorder(
              onRemove: state.addNewProvider,
              onRemoveIcon: const Icon(Icons.add_box),
              child: Text("tap_to_add_new_service_provider".tr),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical40,
                  onPressed: state.updateProviders,
                  child: Text("update_providers".tr),
                )
              ],
            )
          ],
        ),
      ),
    ]);
  }
}

class _ImportProviderWidget extends StatelessWidget {
  const _ImportProviderWidget(this.state, {Key? key}) : super(key: key);
  final __UpdateEthereumNetworkState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetConstant.height20,
          Text("rpc_url".tr, style: context.textTheme.titleMedium),
          Text("rpc_url_desc".tr),
          Text("ethereum_rpc_url_desc"
              .tr
              .replaceOne(state.chainId.toString())
              .replaceTwo(state.chainId.toRadix16)),
          WidgetConstant.height8,
          AppTextField(
            initialValue: state.rpcUrl,
            onChanged: state.onChageUrl,
            validator: state.validateRpcUrl,
            pasteIcon: true,
            label: "rpc_url".tr,
          ),
          WidgetConstant.height20,
          AppSwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("authenticated".tr),
            subtitle: Text("add_provider_authenticated".tr),
            value: state.useAuthenticated,
            onChanged: state.onChangeAuthenticated,
          ),
          APPAnimatedSize(
              isActive: state.useAuthenticated,
              onActive: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetConstant.height8,
                      AppDropDownBottom(
                        items: {
                          for (final i in ProviderAuthType.values)
                            i: Text(i.name.camelCase)
                        },
                        label: "authenticated_type".tr,
                        onChanged: state.onChangeAuthMode,
                        value: state.auth,
                      ),
                      WidgetConstant.height20,
                      AppTextField(
                        label: "authenticated_key".tr,
                        pasteIcon: true,
                        hint: "example_value".tr.replaceOne(state.auth.isHeader
                            ? APPConst.exampleAuthenticatedHeader
                            : APPConst.exampleAuthenticatedQuery),
                        onChanged: state.onChangeKey,
                        validator: state.validateKey,
                      ),
                      AppTextField(
                        pasteIcon: true,
                        label: "authenticated_value".tr,
                        hint: "example_value".tr.replaceOne(state.auth.isHeader
                            ? APPConst.exampleAuthenticatedHeaderValue
                            : APPConst.exampleBase58),
                        onChanged: state.onChangeValue,
                        validator: state.validateValue,
                      ),
                    ],
                  ),
              onDeactive: (c) => WidgetConstant.sizedBox),
          WidgetConstant.height20,
          AppSwitchListTile(
            title: Text("access_in_web3_apps".tr),
            subtitle: Text("access_provider_in_web3_apps_desc".tr),
            contentPadding: EdgeInsets.zero,
            value: state.useInWeb3,
            onChanged: state.onChangeUseInWeb3,
          ),
          Padding(
            padding: WidgetConstant.paddingVertical40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton.icon(
                  label: Text("import_providers".tr),
                  onPressed: state.onUpdate,
                  icon: const Icon(Icons.update),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
