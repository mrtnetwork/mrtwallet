import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/ton/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/permission/ethereum_permission_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

mixin Web3PermissionState<
        T extends StatefulWidget,
        NETWORKADDRESS,
        CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
        ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
        CHAINACCOUT extends Web3ChainAccount<NETWORKADDRESS>,
        WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUT>>
    on SafeState<T> {
  WEB3CHAIN createNewChainPermission();
  CHAINACCOUT createNewAccountPermission(ADDRESS address);

  Future<WEB3CHAIN> getPermission() async {
    final WEB3CHAIN newPermission = createNewChainPermission();
    List<CHAINACCOUT> accounts = [];
    for (final i in permissions.entries) {
      if (i.value.isEmpty) continue;
      final defaultAddresses = i.value.where((e) => e.defaultAddress);
      if (defaultAddresses.isEmpty) {
        i.value.first.changeDefault(true);
      } else if (defaultAddresses.length > 1) {
        for (final e in i.value) {
          e.changeDefault(false);
        }
        i.value.first.changeDefault(true);
      }
      accounts.addAll(i.value);
    }
    newPermission.updateChainAccount(accounts);
    return newPermission;
  }

  late final WEB3CHAIN permission;
  late final List<CHAIN> chains;
  Map<CHAIN, List<CHAINACCOUT>> permissions = {};
  late CHAIN chain;
  List<CHAINACCOUT> get chainPermission => permissions[chain]!;
  void onChangeDefaultPermission(CHAINACCOUT? address) {
    if (address == null) return;
    if (address.defaultAddress) return;
    for (final e in chainPermission) {
      e.changeDefault(false);
    }
    address.changeDefault(true);
    updateState();
  }

  CHAINACCOUT? hasPermission(ADDRESS address) {
    return chainPermission.firstWhereOrNull((e) =>
        e.address == address.networkAddress && e.keyIndex == address.keyIndex);
  }

  void addAccount(ADDRESS address) {
    final exists = hasPermission(address);
    if (exists != null) {
      chainPermission.remove(exists);
    } else {
      chainPermission.add(createNewAccountPermission(address));
    }
    if (chainPermission.isNotEmpty &&
        !chainPermission.any((e) => e.defaultAddress)) {
      chainPermission[0].changeDefault(true);
    }

    updateState();
  }

  void onChangeChain(CHAIN? updateChain) {
    chain = updateChain ?? chain;
    updateState();
  }
}

class Web3PermissionUpdateView extends StatelessWidget {
  const Web3PermissionUpdateView({required this.controller, Key? key})
      : super(key: key);
  final Web3RequestControllerImpl controller;

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      alignment: Alignment.center,
      maxHeight: APPConst.maxDialogHeight,
      padding: WidgetConstant.padding20,
      maxWidth: APPConst.dialogWidth,
      child: ClipRRect(
          borderRadius: WidgetConstant.border25,
          child: PasswordCheckerView(
            accsess: WalletAccsessType.unlock,
            onAccsess: (credential, password, network) =>
                _Web3APPPermissionView(controller: controller),
          )),
    );
  }
}

class _Web3APPPermissionView extends StatefulWidget {
  const _Web3APPPermissionView({required this.controller, Key? key})
      : super(key: key);
  final Web3RequestControllerImpl controller;

  @override
  State<_Web3APPPermissionView> createState() => __Web3APPPermissionViewState();
}

class __Web3APPPermissionViewState extends State<_Web3APPPermissionView>
    with SafeState {
  Web3RequestControllerImpl get controller => widget.controller;
  final GlobalKey<FormState> formKey = GlobalKey();
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

  NetworkType chainType = NetworkType.ethereum;

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
      progressKey.successProgress();
      updateState();
    }
  }

  void onUpdateChainPermission() async {
    final update =
        await permissionState[_selectedIndex]?.currentState?.getPermission();
    Web3APPAuthentication? permission = application;
    if (permission == null) return;
    progressKey.progressText("updating_permission".tr);
    updateState();
    if (update != null) {
      permission.updateChainAccount(update);
    }
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
    updateState();
  }

  int _selectedIndex = 1;
  void changeChain(int index) {
    if (index == 0) {
      _selectedIndex = 0;
      updateState();
      return;
    }
    chainType = Web3Const.supportedWeb3.elementAt(index - 1);
    _selectedIndex = index;
    updateState();
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

  late final Map<int, GlobalKey<Web3PermissionState>> permissionState = {
    1: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_ethereumm"),
    2: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_tron"),
    3: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_solana"),
    4: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_ton"),
    5: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_stellar"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          APPAnimatedSwitcher<bool>(enable: progressKey.inProgress, widgets: {
        false: (context) => FloatingActionButton.extended(
              onPressed: () {
                onUpdateChainPermission();
              },
              label: Text("update_permission".tr),
              icon: const Icon(Icons.save),
            ),
        true: (context) => WidgetConstant.sizedBox,
      }),
      body: PageProgress(
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: StreamWidgetStatus.progress,
        key: progressKey,
        child: (context) => Row(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: APPConst.naviationRailWidth),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          useIndicator: true,
                          onDestinationSelected: changeChain,
                          labelType: NavigationRailLabelType.none,
                          destinations: [
                            const NavigationRailDestination(
                                icon: Icon(Icons.settings),
                                label: WidgetConstant.sizedBox),
                            NavigationRailDestination(
                                icon: CircleAssetsImgaeView(APPConst.eth,
                                    radius: 15),
                                label: WidgetConstant.sizedBox),
                            NavigationRailDestination(
                                icon: CircleAssetsImgaeView(APPConst.trx,
                                    radius: 15),
                                label: WidgetConstant.sizedBox),
                            NavigationRailDestination(
                                icon: CircleAssetsImgaeView(APPConst.sol,
                                    radius: 15),
                                label: WidgetConstant.sizedBox),
                            NavigationRailDestination(
                                icon: CircleAssetsImgaeView(APPConst.ton,
                                    radius: 15),
                                label: WidgetConstant.sizedBox),
                            NavigationRailDestination(
                                icon: CircleAssetsImgaeView(APPConst.stellar,
                                    radius: 15),
                                label: WidgetConstant.sizedBox),
                          ],
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ),
                  ),
                ),
                TappedTooltipView(
                  tooltipWidget: ToolTipView(
                      padding: WidgetConstant.padding5,
                      tooltipWidget: (context) => ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: APPConst.tooltipConstrainedWidth),
                          child: Container(
                              decoration: BoxDecoration(
                                color: context.colors.surface,
                                borderRadius: WidgetConstant.border8,
                              ),
                              padding: WidgetConstant.padding10,
                              child: Web3ClientInfoView(
                                  permission: application!))),
                      child: CircleAPPImageView(application?.icon,
                          radius: 35,
                          onError: (c) => const Icon(Icons.broken_image,
                              size: APPConst.double40))),
                ),
              ],
            ),
            Expanded(child: _APPPermissionWidget(this))
          ],
        ),
      ),
    );
  }
}

class _APPPermissionWidget extends StatelessWidget {
  const _APPPermissionWidget(this.state, {Key? key}) : super(key: key);
  final __Web3APPPermissionViewState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        APPSliverAnimatedSwitcher<int>(enable: state._selectedIndex, widgets: {
          0: (context) => _APPSettingView(state),
          1: (context) => EthereumWeb3PermissionView(
              key: state.permissionState[1],
              permission: state.application
                  ?.getChainFromNetworkType(NetworkType.ethereum)),
          2: (context) => TronWeb3PermissionView(
              key: state.permissionState[2],
              permission:
                  state.application?.getChainFromNetworkType(NetworkType.tron)),
          3: (context) => SolanaWeb3PermissionView(
              key: state.permissionState[3],
              permission: state.application
                  ?.getChainFromNetworkType(NetworkType.solana)),
          4: (context) => TonWeb3PermissionView(
              key: state.permissionState[4],
              permission:
                  state.application?.getChainFromNetworkType(NetworkType.ton)),
          5: (context) => StellarWeb3PermissionView(
              key: state.permissionState[5],
              permission: state.application
                  ?.getChainFromNetworkType(NetworkType.stellar)),
        }),
      ],
    );
  }
}

class _APPSettingView extends StatelessWidget {
  const _APPSettingView(this.state, {Key? key}) : super(key: key);
  final __Web3APPPermissionViewState state;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: WidgetConstant.padding20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Web3ClientInfoView(permission: state.application!),
            WidgetConstant.height20,
            Text("application_name".tr, style: context.textTheme.titleMedium),
            Text("edit_application_name_desc".tr),
            WidgetConstant.height8,
            AppTextField(
              label: "application_name".tr,
              onChanged: state.onChangeName,
              validator: state.validateApplicationName,
              hint: "application_name".tr,
              initialValue: state.applicationName,
            ),
            WidgetConstant.height20,
            AppSwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("web3_activation".tr,
                  style: context.textTheme.titleMedium),
              subtitle: Text("web3_activation_desc".tr),
              maxLine: 3,
              value: state.active,
              onChanged: state.onChangeActivation,
            ),
          ],
        ),
      ),
    );
  }
}
