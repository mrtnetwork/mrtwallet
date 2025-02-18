import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/constant/constant.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class SelectProviderIcon extends StatelessWidget {
  const SelectProviderIcon({super.key, this.icon});
  final Icon? icon;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main).wallet;
    return LiveWidget(() {
      final account = wallet.chain;
      final client = account.clientNullable;
      final APIServiceTracker? provider = client?.service.tracker;

      return IconButton(
        tooltip: provider.message().tr,
        onPressed: () {
          context
              .openSliverDialog<ProviderIdentifier>(
                  (ctx) => SelectProviderView(chain: wallet.chain),
                  "service_provider".tr)
              .then(
            (value) {
              if (value == null) return;
              wallet.changeProvider(provider: value, account: account);
            },
          );
        },
        icon: icon ?? Icon(provider.icon, color: context.colors.onPrimary),
      );
    });
  }
}

class ProviderTrackerStatusView extends StatelessWidget {
  const ProviderTrackerStatusView({super.key, required this.provider});
  final APIServiceTracker provider;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() => ToolTipView(
        message: provider.message().tr,
        waitDuration: null,
        child: Icon(
          Icons.circle,
          color: provider.hasActive ? ColorConst.green : context.colors.error,
        )));
  }
}

class SelectProviderView extends StatelessWidget {
  const SelectProviderView({super.key, required this.chain});
  final APPCHAIN chain;

  @override
  Widget build(BuildContext context) {
    return switch (chain.network.type) {
      NetworkType.aptos => _SelectAptosProviderView(chain.cast()),
      _ => _SelectProviderView(chain: chain)
    };
  }
}

class _SelectProviderView extends StatefulWidget {
  const _SelectProviderView({required this.chain});
  final APPCHAIN chain;

  @override
  State<_SelectProviderView> createState() => _SelectProviderViewState();
}

class _SelectProviderViewState extends State<_SelectProviderView>
    with SafeState {
  WalletNetwork get network => widget.chain.network;
  BaseServiceProtocol? service;

  bool get isTron => network.type == NetworkType.tron;
  late final List<APIProvider> providers;

  void onTapProvider(APIProvider provider) {
    if (provider.identifier == service?.provider.identifier) {
      context
          .openSliverBottomSheet("network_provider_log_details".tr, slivers: [
        _ProviderLogsView(
            tracker: service!.tracker, provider: service!.provider),
      ]);
      return;
    }
    if (isTron) return;
    final identifier = DefaultProviderIdentifier(
        identifier: provider.identifier, network: network.type);
    context.pop(identifier);
  }

  void onUpdateProvider() async {
    await context.to(PageRouter.updateProvider(widget.chain.network),
        argruments: widget.chain.network);
    updateState();
  }

  @override
  void onInitOnce() {
    providers = network.getAllProviders();
    service = widget.chain.clientNullable?.service;
    super.onInitOnce();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("network".tr, style: context.textTheme.titleMedium),
          if (isTron) Text("network_tron_provider_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.coinParam.token.name,
                  style: context.onPrimaryTextTheme.bodyMedium)),
          WidgetConstant.height20,
          Text("choose_provider".tr, style: context.textTheme.titleMedium),
          Text("select_provider_desc".tr),
          WidgetConstant.height8,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final provider = providers.elementAt(index);
              final bool isSelected =
                  service?.provider.identifier == provider.identifier;
              return _ProviderView(
                  onTapProvider: onTapProvider,
                  provider: provider,
                  isSelected: isSelected,
                  tracker: service?.tracker.icon);
            },
            itemCount: providers.length,
          ),
          if (network.supportCustomNode)
            ContainerWithBorder(
              onRemove: onUpdateProvider,
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              child: Text("network_add_provider".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

typedef _ONTAPPROVIDER<T extends APIProvider> = Function(T);

class _ProviderView<T extends APIProvider> extends StatelessWidget {
  const _ProviderView({
    super.key,
    required this.onTapProvider,
    required this.provider,
    required this.isSelected,
    this.tracker,
  });
  final bool isSelected;
  final IconData? tracker;
  final T provider;
  final _ONTAPPROVIDER<T> onTapProvider;

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemoveIcon: isSelected
          ? Icon(tracker, color: context.onPrimaryContainer)
          : WidgetConstant.sizedBox,
      onRemove: () => onTapProvider(provider),
      enableTap: isSelected ? false : true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.protocol.value.tr,
                      style: context.colors.onPrimaryContainer
                          .lableLarge(context)),
                  Text(provider.callUrl,
                      style:
                          context.colors.onPrimaryContainer.bodyMedium(context),
                      maxLines: 2),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectAptosProviderView extends StatefulWidget {
  const _SelectAptosProviderView(this.chain);
  final AptosChain chain;

  @override
  State<_SelectAptosProviderView> createState() =>
      __SelectAptosProviderViewState();
}

class __SelectAptosProviderViewState extends State<_SelectAptosProviderView>
    with SafeState<_SelectAptosProviderView> {
  WalletAptosNetwork get network => widget.chain.network;
  AptosHTTPService? service;
  List<AptosAPIProvider> fullNodeProvers = [];
  List<AptosAPIProvider> graphQlProviders = [];
  void onTapProvider(AptosAPIProvider provider) {
    if (provider.identifier == service?.provider.identifier) {
      context
          .openSliverBottomSheet("network_provider_log_details".tr, slivers: [
        _ProviderLogsView(
            tracker: service!.tracker, provider: service!.provider),
      ]);
      return;
    }
    AptosProviderIdentifier? identifier;
    switch (provider.type) {
      case AptosAPIProviderType.fullnode:
        final graphQL = graphQlProviders.firstWhereOrNull(
            (e) => e.identifier == service?.graphQlProvider.identifier,
            orElse: () => graphQlProviders.firstOrNull);
        if (graphQL != null) {
          identifier = AptosProviderIdentifier(
              fullNodeIdentifier: provider.identifier,
              graphQlIdentifier: graphQL.identifier);
        }

        break;
      case AptosAPIProviderType.graphQl:
        final fullNode = fullNodeProvers.firstWhereOrNull(
            (e) => e.identifier == service?.provider.identifier,
            orElse: () => fullNodeProvers.firstOrNull);
        if (fullNode != null) {
          identifier = AptosProviderIdentifier(
              fullNodeIdentifier: fullNode.identifier,
              graphQlIdentifier: provider.identifier);
        }
        break;
    }
    if (identifier != null) {
      context.pop(identifier);
    }
  }

  void onUpdateProvider() async {
    await context.to(PageRouter.updateProvider(widget.chain.network),
        argruments: widget.chain.network);
    updateState();
  }

  void checkProviders() {
    final allProviders = network.getAllProviders().cast<AptosAPIProvider>();
    fullNodeProvers = allProviders
        .where((e) => e.type == AptosAPIProviderType.fullnode)
        .toList();
    graphQlProviders = allProviders
        .where((e) => e.type == AptosAPIProviderType.graphQl)
        .toList();
    service = widget.chain.clientNullable?.service;
  }

  @override
  void onInitOnce() {
    checkProviders();
    super.onInitOnce();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("network".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(network.coinParam.token.name,
                  style: context.onPrimaryTextTheme.bodyMedium)),
          WidgetConstant.height20,
          Text("choose_provider".tr, style: context.textTheme.titleMedium),
          Text("aptos_select_provider_desc".tr),
          WidgetConstant.height20,
          Text("full_node".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final provider = fullNodeProvers.elementAt(index);
              final bool isSelected =
                  service?.provider.identifier == provider.identifier;
              return _ProviderView(
                  onTapProvider: onTapProvider,
                  provider: provider,
                  isSelected: isSelected,
                  tracker: service?.tracker.icon);
            },
            itemCount: fullNodeProvers.length,
          ),
          WidgetConstant.height20,
          Text("graphql".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.builder(
              physics: WidgetConstant.noScrollPhysics,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final provider = graphQlProviders.elementAt(index);
                final bool isSelected =
                    service?.graphQlProvider.identifier == provider.identifier;
                return _ProviderView(
                    onTapProvider: onTapProvider,
                    provider: provider,
                    isSelected: isSelected,
                    tracker: service?.tracker.icon);
              },
              itemCount: graphQlProviders.length),
          if (network.supportCustomNode)
            ContainerWithBorder(
              onRemove: onUpdateProvider,
              onRemoveIcon:
                  Icon(Icons.add_box, color: context.onPrimaryContainer),
              child: Text("network_add_provider".tr,
                  style: context.onPrimaryTextTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

extension _TooltipMessage on APIServiceTracker? {
  String message() {
    if (this == null) {
      return "network_no_provider_detected";
    }
    switch (this?.status) {
      case APIServiceStatus.active:
        return "no_error_found";
      case APIServiceStatus.error:
        return "network_all_request_error";
      default:
        return "network_some_request_error";
    }
  }
}

extension _TrackerIcon on APIServiceTracker? {
  IconData get icon {
    if (this == null) {
      return Icons.error;
    }
    switch (this?.status) {
      case APIServiceStatus.active:
        return Icons.check_circle;
      case APIServiceStatus.error:
        return Icons.error;
      default:
        return Icons.warning;
    }
  }
}

class _ProviderRequestView extends StatefulWidget {
  const _ProviderRequestView({required this.provider});
  final APIServiceTracker provider;

  @override
  State<_ProviderRequestView> createState() => _ProviderRequestViewState();
}

class _ProviderRequestViewState extends State<_ProviderRequestView>
    with SafeState {
  ApiRequest? full;

  void onSetFullView(ApiRequest? request) {
    full = request;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final requets = widget.provider.requests;
    return SliverList.builder(
        itemCount: requets.length,
        itemBuilder: (context, index) {
          final request = requets[index];
          final int? maxLine = full == request ? null : 1;
          return AnimatedSize(
            duration: APPConst.animationDuraion,
            alignment: Alignment.topCenter,
            child: ContainerWithBorder(
                key: ValueKey<int?>(maxLine),
                onRemove: () {
                  onSetFullView(request);
                },
                onRemoveWidget: WidgetConstant.sizedBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(request.time.toDateAndTime(),
                            style: context.onPrimaryTextTheme.labelSmall),
                      ],
                    ),
                    Text("url".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      onRemove: () {},
                      onRemoveIcon: CopyTextIcon(
                        dataToCopy: request.uri,
                        isSensitive: false,
                        color: context.primaryContainer,
                      ),
                      enableTap: false,
                      child: Text(
                        request.uri,
                        style: context.primaryTextTheme.bodyMedium,
                        maxLines: maxLine,
                      ),
                    ),
                    if (request.error != null) ...[
                      WidgetConstant.height20,
                      Text("error".tr,
                          style: context.onPrimaryTextTheme.titleMedium),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                        backgroundColor: context.colors.error,
                        child: Text(
                          request.error!.toString().tr,
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: context.colors.onError),
                          maxLines: maxLine,
                        ),
                      ),
                    ],
                  ],
                )),
          );
        });
  }
}

class _ProviderLogsView extends StatefulWidget {
  const _ProviderLogsView({required this.tracker, required this.provider});
  final APIServiceTracker tracker;
  final APIProvider provider;

  @override
  State<_ProviderLogsView> createState() => _ProviderLogsViewState();
}

class _ProviderLogsViewState extends State<_ProviderLogsView> with SafeState {
  ApiRequest? full;

  void onSetFullView(ApiRequest? request) {
    full = request;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final requets = widget.tracker.requests;
    return SliverConstraintsBoxView(
      padding: WidgetConstant.paddingHorizontal20,
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: ConstraintsBoxView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("status".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {},
                    onRemoveIcon: Icon(widget.tracker.icon,
                        color: context.colors.onPrimaryContainer),
                    child: Text(
                      widget.tracker.message().tr,
                      style: context.onPrimaryTextTheme.bodyMedium,
                    ),
                  ),
                  WidgetConstant.height20,
                  Text("provider".tr, style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                    onRemove: () {},
                    onRemoveWidget: LaunchBrowserIcon(
                      url: widget.provider.callUrl,
                      color: context.colors.onPrimaryContainer,
                    ),
                    enableTap: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.protocol.value.tr,
                          style: context.onPrimaryTextTheme.labelLarge,
                        ),
                        SelectableText(
                          widget.provider.callUrl,
                          style: context.onPrimaryTextTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  WidgetConstant.height20,
                  Text("network_total_request".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: Text(
                    widget.tracker.requestCount.toString().to3Digits,
                    style: context.onPrimaryTextTheme.bodyMedium,
                  )),
                  WidgetConstant.height20,
                  Text("network_total_success_request".tr,
                      style: context.textTheme.titleMedium),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      child: Text(
                    widget.tracker.totalSuccess.toString().to3Digits,
                    style: context.onPrimaryTextTheme.bodyMedium,
                  )),
                  if (requets.isNotEmpty) ...[
                    WidgetConstant.height20,
                    Text("network_request_details".tr,
                        style: context.textTheme.titleMedium),
                    WidgetConstant.height8,
                  ]
                ],
              ),
            ),
          ),
          _ProviderRequestView(provider: widget.tracker)
        ],
      ),
    );
  }
}
