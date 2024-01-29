import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/chain/defauilt_node_providers.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';

class SelectProviderIcon extends StatelessWidget {
  const SelectProviderIcon({super.key, this.icon});
  final Icon? icon;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    return LiveWidget(() {
      final ApiProviderTracker<ApiProviderService>? provider =
          wallet.chain.provider()?.serviceProvider;
      final bool supportCustomNode =
          wallet.network is! AppXRPNetwork && wallet.network is! APPTVMNetwork;
      return IconButton(
        tooltip: provider.message().tr,
        onPressed: () {
          context.openSliverDialog(
              (ctx) => _SelectProviderView(
                    network: wallet.network,
                    selectedProvider: provider,
                    supportCustomNode: supportCustomNode,
                  ), content: (context) {
            return supportCustomNode
                ? [
                    WidgetConstant.width8,
                    IconButton(
                        onPressed: () {
                          context.pop(true);
                        },
                        icon: const Icon(Icons.edit))
                  ]
                : [];
          }, "service_provider".tr).then(
            (value) {
              if (value == null) return;
              if (value is ApiProviderService) {
                wallet.changeProvider(value);
              } else {
                context.to(PagePathConst.providerDetails(wallet.chain.network),
                    argruments: wallet.chain.network);
              }
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
  final ApiProviderTracker provider;
  @override
  Widget build(BuildContext context) {
    return LiveWidget(() => ToolTipView(
        message: provider.message().tr,
        waitDuration: null,
        child: Icon(
          Icons.circle,
          color: provider.hasActive ? CustomColors.green : context.colors.error,
        )));
  }
}

class _SelectProviderView extends StatelessWidget {
  const _SelectProviderView(
      {required this.selectedProvider,
      required this.network,
      this.supportCustomNode = false});
  final ApiProviderTracker<ApiProviderService>? selectedProvider;
  final AppNetworkImpl network;
  final bool supportCustomNode;
  bool get isTVM => network is APPTVMNetwork;
  @override
  Widget build(BuildContext context) {
    Set<ApiProviderService> providers = {
      ...DefaultNodeProviders.getDefaultServices(network),
      ...network.coinParam.providers.where((element) => element.protocol.platforms.contains(PlatformInterface.appPlatform)),
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitleSubtitle(
              title: "what_is_service_provider".tr,
              body: LargeTextView(["what_is_api_provider".tr])),
          Text("network".tr, style: context.textTheme.titleMedium),
          if (isTVM) Text("network_tron_provider_desc".tr),
          WidgetConstant.height8,
          ContainerWithBorder(child: Text(network.coinParam.token.name)),
          WidgetConstant.height20,
          if (providers.isNotEmpty) ...[
            Text("choose_provider".tr, style: context.textTheme.titleMedium),
            Text("select_provider_desc".tr),
            WidgetConstant.height8,
            ListView.builder(
              physics: WidgetConstant.noScrollPhysics,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final provider = providers.elementAt(index);
                final bool isSelected = selectedProvider?.provider == provider;
                return ContainerWithBorder(
                  onRemoveIcon: isSelected
                      ? Icon(selectedProvider.icon,
                          color: context.colors.onPrimaryContainer)
                      : WidgetConstant.sizedBox,
                  onRemove: (isTVM && !isSelected)
                      ? null
                      : () {
                          if (isSelected || isTVM) {
                            context.openSliverBottomSheet(
                                "network_provider_log_details".tr,
                                child: _ProviderLogsView(
                                    provider: selectedProvider!));
                            return;
                          }
                          if (isTVM) return;
                          context.pop(provider);
                        },
                  onTapWhenOnRemove: isSelected ? false : true,
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
                              Text(provider.serviceName,
                                  style: context.textTheme.labelLarge),
                              Text(provider.websiteUri),
                              Text(provider.protocol.value),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                );
              },
              itemCount: providers.length,
            ),
          ] else if (supportCustomNode)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "network_no_provider_detected".tr,
                        textAlign: TextAlign.center,
                      ),
                      WidgetConstant.height15,
                      FixedElevatedButton(
                        onPressed: () {
                          context.pop(true);
                        },
                        child: Text("network_add_provider".tr),
                      )
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

extension _TooltipMessage on ApiProviderTracker? {
  String message() {
    if (this == null) {
      return "network_no_provider_detected";
    }
    switch (this?.status) {
      case ApiProviderStatus.active:
        return "no_error_found";
      case ApiProviderStatus.error:
        return "network_all_request_error";
      default:
        return "network_some_request_error";
    }
  }
}

extension _TrackerIcon on ApiProviderTracker? {
  IconData get icon {
    if (this == null) {
      return Icons.error;
    }
    switch (this?.status) {
      case ApiProviderStatus.active:
        return Icons.check_circle;
      case ApiProviderStatus.error:
        return Icons.error;
      default:
        return Icons.warning;
    }
  }
}

class _ProviderLogsView extends StatefulWidget {
  const _ProviderLogsView({required this.provider});
  final ApiProviderTracker provider;

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
    final requets = widget.provider.requests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("status".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {},
          onRemoveIcon: Icon(
            widget.provider.icon,
            color: context.colors.onPrimaryContainer,
          ),
          child: Text(widget.provider.message().tr),
        ),
        WidgetConstant.height20,
        Text("network_total_request".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Text(widget.provider.requestCount.toString().to3Digits)),
        WidgetConstant.height20,
        Text("network_total_success_request".tr,
            style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Text(widget.provider.totalSuccess.toString().to3Digits)),
        if (requets.isNotEmpty) ...[
          WidgetConstant.height20,
          Text("network_request_details".tr,
              style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final request = requets[index];
              int? maxLine = full == request ? null : 1;
              return AnimatedSize(
                duration: AppGlobalConst.animationDuraion,
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
                                style: context.textTheme.labelSmall),
                          ],
                        ),
                        if (request.uri != null) ...[
                          Text("url".tr, style: context.textTheme.titleSmall),
                          ContainerWithBorder(
                            backgroundColor: context.colors.secondary,
                            onRemoveIcon:
                                CopyTextIcon(dataToCopy: request.uri!),
                            onTapWhenOnRemove: false,
                            child: Text(
                              request.uri!,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onSecondary),
                              maxLines: maxLine,
                            ),
                          ),
                        ],
                        if (request.params != null) ...[
                          Text("request".tr,
                              style: context.textTheme.titleSmall),
                          ContainerWithBorder(
                            backgroundColor: context.colors.secondary,
                            onRemove: () {},
                            onRemoveIcon:
                                CopyTextIcon(dataToCopy: request.params!),
                            onTapWhenOnRemove: false,
                            child: Text(
                              request.params!,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onSecondary),
                              maxLines: maxLine,
                            ),
                          ),
                        ],
                        if (request.error != null) ...[
                          Text("error".tr, style: context.textTheme.titleSmall),
                          ContainerWithBorder(
                            backgroundColor: context.colors.error,
                            child: Text(
                              request.error!.message?.tr ?? "",
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onError),
                              maxLines: maxLine,
                            ),
                          ),
                        ],
                        if (request.response != null) ...[
                          Text("response".tr,
                              style: context.textTheme.titleSmall),
                          ContainerWithBorder(
                            backgroundColor: context.colors.secondary,
                            onRemove: () {},
                            onRemoveIcon:
                                CopyTextIcon(dataToCopy: request.response!),
                            onTapWhenOnRemove: false,
                            child: Text(
                              request.response!,
                              style: context.textTheme.bodyMedium
                                  ?.copyWith(color: context.colors.onSecondary),
                              maxLines: maxLine,
                            ),
                          ),
                        ]
                      ],
                    )),
              );
            },
            itemCount: requets.length,
            addAutomaticKeepAlives: false,
            physics: WidgetConstant.noScrollPhysics,
          ),
        ]
      ],
    );
  }
}
