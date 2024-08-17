import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/permission/ethereum_permission_view.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/access/wallet_access.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';

typedef OnUpdateChainPermission = void Function(Web3Chain update);

class Web3PermissionUpdateView extends StatelessWidget {
  const Web3PermissionUpdateView(
      {required this.controller, required this.scrollController, Key? key})
      : super(key: key);
  final Web3RequestControllerImpl controller;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) => _Web3APPPermissionView(
          controller: controller, scrollController: scrollController),
      title: "update_permission".tr,
    );
  }
}

class _Web3APPPermissionView extends StatefulWidget {
  const _Web3APPPermissionView(
      {required this.controller, required this.scrollController, Key? key})
      : super(key: key);
  final Web3RequestControllerImpl controller;
  final ScrollController scrollController;

  @override
  State<_Web3APPPermissionView> createState() => __Web3APPPermissionViewState();
}

class __Web3APPPermissionViewState extends State<_Web3APPPermissionView>
    with SafeState {
  late Web3RequestControllerImpl controller = widget.controller;
  final GlobalKey<FormState> formKey = GlobalKey();
  late final bool multipleChains = Web3Const.supportedWeb3.length > 1;
  Web3APPAuthentication? application;

  String applicationName = "";

  bool active = true;

  void onChangeName(String v) {
    applicationName = v;
  }

  void onChangeActivation(bool? _) {
    active = !active;
    updateState();
  }

  String? validateApplicationName(String? v) {
    if (v == null || v.trim().length < 3) {
      return "application_name_validator".tr;
    }
    return null;
  }

  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  NetworkType chainType = Web3Const.supportedWeb3.first;

  Future<void> onChangePermission() async {
    application = await controller.getCurrentApplication();
    applicationName = application?.name ?? "";
    active = application?.active ?? true;
    if (application == null) {
      progressKey.success(
          backToIdle: false,
          progressWidget: ProgressWithTextView(
              icon: const Icon(Icons.insert_page_break_rounded,
                  size: APPConst.double80),
              text: "web_application_not_valid".tr));
    } else {
      progressKey.backToIdle();
      updateState();
    }
  }

  void onUpdateChainPermission(Web3Chain update) async {
    Web3APPAuthentication? permission = application;
    if (permission == null) return;
    progressKey.progressText("updating_permission".tr);
    permission.updateChainAccount(update);
    if (permission.name != applicationName || permission.active != active) {
      permission = permission.clone(active: active, name: applicationName);
    }
    final result = await MethodUtils.call(
        () async => await controller.updatePermission(permission!));
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.success();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => onChangePermission());
  }

  @override
  void didUpdateWidget(covariant _Web3APPPermissionView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: PageProgress(
          initialStatus: StreamWidgetStatus.progress,
          key: progressKey,
          backToIdle: APPConst.oneSecoundDuration,
          child: (c) => CustomScrollView(
                controller: widget.scrollController,
                // mainAxisSize: MainAxisSize.max,
                slivers: [
                  SliverConstraintsBoxView(
                      padding: WidgetConstant.paddingHorizontal20,
                      sliver: SliverMainAxisGroup(slivers: [
                        SliverToBoxAdapter(
                            child:
                                Web3ClientInfoView(permission: application!)),
                        WidgetConstant.sliverPaddingVertial20,
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("application_name".tr,
                                  style: context.textTheme.titleMedium),
                              Text("edit_application_name_desc".tr),
                              WidgetConstant.height8,
                              AppTextField(
                                label: "application_name".tr,
                                onChanged: onChangeName,
                                validator: validateApplicationName,
                                hint: "application_name".tr,
                                initialValue: applicationName,
                              ),
                              WidgetConstant.height20,
                              AppSwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("web3_activation".tr,
                                    style: context.textTheme.titleMedium),
                                subtitle: Text("web3_activation_desc".tr),
                                maxLine: 3,
                                value: active,
                                onChanged: onChangeActivation,
                              )
                            ],
                          ),
                        ),
                        WidgetConstant.sliverPaddingVertial20,
                        APPSliverAnimatedSwitcher(enable: chainType, widgets: {
                          NetworkType.ethereum: (c) =>
                              EthereumWeb3PermissionView(
                                  permission:
                                      application?.getChainFromNetworkType(
                                          NetworkType.ethereum),
                                  onUpdateChainPermission:
                                      onUpdateChainPermission),
                        })
                      ]))
                ],
              )),
    );
  }
}
