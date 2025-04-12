import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/wallet/web3/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/access/wallet_access.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'appbar_action.dart';
import 'client_info.dart';
import 'page_progress.dart';

typedef Web3PageChainBuilder<T extends Web3NetworkRequestControllerState>
    = List<Widget> Function(BuildContext context, T controller);

class Web3NetworkPageRequestControllerView<
    T extends Web3NetworkRequestControllerState> extends StatelessWidget {
  const Web3NetworkPageRequestControllerView(
      {super.key,
      required this.request,
      required this.builder,
      required this.controller,
      this.showRequestAccount = true,
      this.width = APPConst.maxViewWidth});
  final Web3PageChainBuilder<T> builder;
  final T Function() controller;
  final Web3NetworkRequest request;
  final bool showRequestAccount;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        request.reject();
      },
      child: PasswordCheckerView(
        appbar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.params.method.name.tr),
              Text(request.params.method.name,
                  style: context.textTheme.bodySmall),
            ],
          ),
          actions: [
            Web3PermissionAppbarActionView(request: request),
            WidgetConstant.width8,
          ],
        ),
        accsess: WalletAccsessType.unlock,
        subtitle: Web3ClientInfoView(
            permission: request.authenticated, info: request.info),
        onAccsess: (_, __, ___) {
          return MrtViewBuilder(
              controller: controller,
              builder: (controller) {
                final bool hasAccount = controller.permissionAccount != null;
                return Web3PageProgress(
                    key: controller.progressKey,
                    initialStatus: Web3ProgressStatus.progress,
                    initialWidget: PageProgressChildWidget(ProgressWithTextView(
                        text: "web3_retrieval_requirment".tr)),
                    child: (context) => CustomScrollView(slivers: [
                          SliverConstraintsBoxView(
                              maxWidth: width,
                              padding: WidgetConstant.paddingHorizontal20,
                              sliver: SliverMainAxisGroup(slivers: [
                                WidgetConstant.sliverPaddingVertial20,
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showRequestAccount && hasAccount) ...[
                                        Text("account".tr,
                                            style:
                                                context.textTheme.titleMedium),
                                        Text("web3_request_account_desc".tr),
                                        WidgetConstant.height8,
                                        ContainerWithBorder(
                                            child: AddressDetailsView(
                                                address: controller
                                                    .permissionAccount!,
                                                color: context
                                                    .onPrimaryContainer)),
                                        WidgetConstant.height20
                                      ],
                                    ],
                                  ),
                                ),
                                ...builder(context, controller)
                              ])),
                        ]));
              },
              repositoryId: request.info.request.requestId);
        },
      ),
    );
  }
}

typedef WEB3GLOBALPAGEBUILDER<T extends Web3GlobalRequestControllerState>
    = Widget Function(BuildContext context, T controller);

class Web3GlobalPageRequestControllerView<
    T extends Web3GlobalRequestControllerState> extends StatelessWidget {
  const Web3GlobalPageRequestControllerView(
      {super.key,
      required this.request,
      required this.builder,
      required this.controller,
      this.width = APPConst.maxViewWidth});
  final WEB3GLOBALPAGEBUILDER<T> builder;
  final T Function() controller;
  final Web3GlobalRequest request;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        request.reject();
      },
      child: PasswordCheckerView(
        appbar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.params.method.name.tr),
              Text(request.params.method.name,
                  style: context.textTheme.bodySmall)
            ],
          ),
        ),
        accsess: WalletAccsessType.unlock,
        subtitle: Web3ClientInfoView(
            permission: request.authenticated, info: request.info),
        onAccsess: (_, __, ___) {
          return MrtViewBuilder(
              controller: controller,
              builder: (controller) {
                return Web3PageProgress(
                    key: controller.progressKey,
                    initialStatus: Web3ProgressStatus.progress,
                    initialWidget: ProgressWithTextView(
                        text: "web3_retrieval_requirment".tr),
                    child: (context) => builder(context, controller));
              },
              repositoryId: request.info.request.requestId);
        },
      ),
    );
  }
}
