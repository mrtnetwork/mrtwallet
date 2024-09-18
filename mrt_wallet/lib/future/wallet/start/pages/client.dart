import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class NetworkClientConnectionSliverHeaderDelegate extends StatelessWidget {
  final WalletProvider wallet;
  const NetworkClientConnectionSliverHeaderDelegate(this.wallet, {super.key});
  Chain get chainAccount => wallet.wallet.chain;
  WalletNetwork get network => chainAccount.network;
  NetworkClient? get client => chainAccount.provider();
  bool get hasProvider => client != null;
  NodeClientStatus? get status => client?.status.value;
  bool get isConnect => status?.isConnect ?? false;
  void onSwitchNetwork(BuildContext context) {
    context.openSliverDialog(
        (ctx) => SelectProviderView(
              network: network,
              service: client?.service,
            ), content: (context) {
      return network.supportCustomNode
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
        if (value is APIProvider) {
          wallet.wallet.changeProvider(account: chainAccount, provider: value);
        } else {
          context.to(PageRouter.providerDetails(network), argruments: network);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: context.colors.errorContainer,
      foregroundColor: context.colors.onErrorContainer,
      centerTitle: false,
      toolbarHeight: isConnect ? 0 : 70,
      flexibleSpace: Material(
        elevation: 25,
        color: context.colors.transparent,
        type: MaterialType.button,
        child: AnimatedContainer(
          duration: APPConst.animationDuraion,
          padding: WidgetConstant.padding5,
          color: (status?.isPending ?? false)
              ? context.colors.tertiaryContainer
              : context.colors.errorContainer,
          child: APPAnimatedSwitcher(enable: status, widgets: {
            null: (c) => _NoProvider(
                  () {
                    onSwitchNetwork(context);
                  },
                ),
            NodeClientStatus.disconnect: (c) => _DisconnectStatus(
                onTry: () => client?.init(),
                onEdit: () => onSwitchNetwork(context)),
            NodeClientStatus.pending: (c) => const _PendingStatus(),
            NodeClientStatus.connect: (c) => WidgetConstant.sizedBox
          }),
        ),
      ),
    );
  }
}

class _NoProvider extends StatelessWidget {
  const _NoProvider(this.onTry, {Key? key}) : super(key: key);
  final DynamicVoid onTry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "network_no_provider_detected".tr,
                style: context.textTheme.labelLarge
                    ?.copyWith(color: context.colors.onErrorContainer),
              )
            ],
          ),
        ),
        IconButton(
            onPressed: onTry,
            icon: Icon(Icons.add, color: context.colors.onErrorContainer))
      ],
    );
  }
}

class _DisconnectStatus extends StatelessWidget {
  const _DisconnectStatus({required this.onEdit, required this.onTry, Key? key})
      : super(key: key);
  final DynamicVoid onTry;
  final DynamicVoid onEdit;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTry,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "connection_attempt_unsuccessful".tr,
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: context.colors.onErrorContainer),
                  maxLines: 1,
                ),
                Text("node_connection_desc".tr,
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: context.colors.onErrorContainer),
                    maxLines: 2)
              ],
            ),
          ),
        ),
        IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: context.colors.onErrorContainer))
      ],
    );
  }
}

class _PendingStatus extends StatelessWidget {
  const _PendingStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("node_connectiong_please_wait".tr,
                              style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.onTertiaryContainer)),
                          Text(
                            "node_connection_desc".tr,
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onErrorContainer),
                            maxLines: 2,
                          )
                        ],
                      ),
                    ),
                    WidgetConstant.width8,
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                          color: context.colors.onTertiaryContainer),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
