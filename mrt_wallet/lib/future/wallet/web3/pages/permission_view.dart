import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/sui/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/ton/web3/permission/permission.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/wallet/web3/global/connect/controller/connect.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/client_info.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/web3/permission/ethereum_permission_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class Web3PermissionUpdateView extends StatelessWidget {
  const Web3PermissionUpdateView({required this.controller, super.key});
  final Web3RequestControllerImpl controller;

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      alignment: Alignment.center,
      padding: WidgetConstant.paddingHorizontal20,
      maxWidth: APPConst.dialogWidth,
      child: ClipRRect(
          borderRadius: WidgetConstant.border25,
          child: PasswordCheckerView(
              appbar: AppBar(
                title: Text('web3_permission'.tr,
                    style: context.textTheme.titleMedium),
              ),
              accsess: WalletAccsessType.unlock,
              onAccsess: (credential, password, network) =>
                  Web3ApplicationPermissionView(controller: controller))),
    );
  }
}

class Web3ApplicationPermissionView extends StatefulWidget {
  const Web3ApplicationPermissionView(
      {super.key, this.controller, this.web3RequestController});
  final Web3RequestControllerImpl? controller;
  final Web3GlobalRequestConnectStateController? web3RequestController;

  @override
  State<Web3ApplicationPermissionView> createState() =>
      __Web3APPPermissionViewState();
}

class __Web3APPPermissionViewState extends State<Web3ApplicationPermissionView>
    with SafeState {
  Web3RequestControllerImpl? get controller => widget.controller;
  Web3GlobalRequestConnectStateController? get web3RequestController =>
      widget.web3RequestController;
  final GlobalKey<FormState> formKey = GlobalKey();
  Web3APPAuthentication? currentApplication;
  Web3APPAuthentication? application;
  List<Web3AccountAcitvity> activities = [];
  String applicationName = "";
  NetworkType? get lockedNetwork => web3RequestController?.network;
  NetworkType chainType = NetworkType.ethereum;
  bool showUpdateButton = false;
  int _selectedIndex = 1;
  bool active = true;

  bool chainDisabled(NetworkType type) {
    return lockedNetwork != null && type != lockedNetwork;
  }

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

  Future<Web3APPAuthentication?> getApplication() async {
    return (web3RequestController?.web3Request.authenticated ??
        await controller?.getCurrentApplication());
  }

  void findInitNetwork() {
    final lockedNetwork = this.lockedNetwork;
    if (lockedNetwork == null) return;
    chainType = lockedNetwork;
    final lockedNetworkIndex = Web3Const.supportedWeb3.indexOf(lockedNetwork);
    _selectedIndex = lockedNetworkIndex + 1;
  }

  Future<void> onChangePermission() async {
    currentApplication = await getApplication();
    application = currentApplication?.clone();
    applicationName = application?.name ?? "";
    active = application?.active ?? true;
    findInitNetwork();
    if (application == null) {
      progressKey.success(
          backToIdle: false,
          progressWidget: ProgressWithTextView(
              icon: const Icon(Icons.insert_page_break_rounded,
                  size: APPConst.double80),
              text: "web_application_not_valid".tr));
    } else {
      progressKey.successProgress();
      showUpdateButton = true;
      updateState();
    }
  }

  Future<void> onUpdateChainPermission() async {
    Web3APPAuthentication? currentPermission = currentApplication;
    Web3APPAuthentication? permission = application;
    if (permission == null || currentPermission == null) return;
    final wallet = context.wallet;
    List<NetworkType> updatedNetwork = [];
    permissionState[_selectedIndex]?.currentState?.updateApplication();
    progressKey.progressText("updating_permission".tr);
    showUpdateButton = false;
    updateState();
    for (final i in Web3Const.supportedWeb3) {
      final updatePermission = permission.getChain(i);
      final oldPermission = currentPermission.getChain(i);
      if (updatePermission == null) continue;

      if (updatePermission == oldPermission) continue;
      if (!updatePermission.hasAccount) {
        if (oldPermission == null || !oldPermission.hasAccount) continue;
      }
      currentPermission.updateChainAccount(updatePermission.clone());
      updatedNetwork.add(i);
    }
    if (permission.name != applicationName) {
      currentPermission.updateApplicationName(permission.name);
      permission.updateApplicationName(permission.name);
    }
    if (permission.active != active) {
      currentPermission.toggleActive();
      permission.toggleActive();
      updatedNetwork = Web3Const.supportedWeb3.clone();
    }

    if (controller != null) {
      final message = await wallet.wallet.updateWeb3Application(
          currentPermission,
          web3Networks: updatedNetwork);
      if (message.hasError) {
        progressKey.errorText(message.error!.tr);
      } else {
        final result = await MethodUtils.call(() async => await controller!
            .sendMessageToClient(
                message.result, currentPermission.applicationId));
        if (result.hasError) {
          progressKey.errorText(result.error!.tr);
        } else {
          progressKey.success();
        }
      }

      showUpdateButton = true;
      updateState();
    } else {
      await web3RequestController!.onUpdateApplication(updatedNetwork);
    }
  }

  void changeChain(int index) {
    if (index == 0) {
      _selectedIndex = 0;
      updateState();
      return;
    }
    permissionState[_selectedIndex]?.currentState?.updateApplication();
    final lockedNetwork = this.lockedNetwork;
    if (lockedNetwork != null) {
      final lockedNetworkIndex = Web3Const.supportedWeb3.indexOf(lockedNetwork);
      if (index - 1 == lockedNetworkIndex) {
        _selectedIndex = index;
        updateState();
      }
      return;
    }

    chainType = Web3Const.supportedWeb3.elementAt(index - 1);
    _selectedIndex = index;
    updateState();
  }

  Future<void> clearActivities() async {
    final application = this.application;
    if (application == null) return;
    final r = await context.openSliverDialog<bool>(
        (context) => DialogTextView(
              text: "delete_all_activities_desc2".tr,
              buttonWidget: DialogDoubleButtonView(),
            ),
        'remove_activities'.tr);
    if (r != true) return;

    progressKey.progressText("updating_permission".tr);
    updateState();
    application.clearActivities();
    final update =
        (await context.wallet.wallet.updateWeb3Application(application));
    if (update.hasError) {
      progressKey.errorText(update.error!.tr);
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
  void didUpdateWidget(covariant Web3ApplicationPermissionView oldWidget) {
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
    6: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_substrate"),
    7: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_aptos"),
    8: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_sui"),
    9: GlobalKey<Web3PermissionState>(debugLabel: "Web3PermissionState_cosmos"),
    10: GlobalKey<Web3PermissionState>(
        debugLabel: "Web3PermissionState_bitcoin"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: APPAnimatedSwitcher<bool>(
          enable: showUpdateButton,
          duration: APPConst.oneSecoundDuration,
          widgets: {
            true: (context) => FloatingActionButton.extended(
                onPressed: onUpdateChainPermission,
                label: Text("update_permission".tr),
                icon: const Icon(Icons.save)),
            false: (context) => WidgetConstant.sizedBox
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
                            _NavigationRailDestination(
                                image: APPConst.eth,
                                disabled: chainDisabled(NetworkType.ethereum)),
                            _NavigationRailDestination(
                                image: APPConst.trx,
                                disabled: chainDisabled(NetworkType.tron)),
                            _NavigationRailDestination(
                                image: APPConst.sol,
                                disabled: chainDisabled(NetworkType.solana)),
                            _NavigationRailDestination(
                                image: APPConst.ton,
                                disabled: chainDisabled(NetworkType.ton)),
                            _NavigationRailDestination(
                                image: APPConst.stellar,
                                disabled: chainDisabled(NetworkType.stellar)),
                            _NavigationRailDestination(
                                image: APPConst.polkadot,
                                disabled: chainDisabled(NetworkType.substrate)),
                            _NavigationRailDestination(
                                image: APPConst.aptos,
                                disabled: chainDisabled(NetworkType.aptos)),
                            _NavigationRailDestination(
                                image: APPConst.sui,
                                disabled: chainDisabled(NetworkType.sui)),
                            _NavigationRailDestination(
                                image: APPConst.atom,
                                disabled: chainDisabled(NetworkType.cosmos)),
                            _NavigationRailDestination(
                                image: APPConst.btc,
                                disabled: chainDisabled(
                                    NetworkType.bitcoinAndForked)),
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
                      child: Padding(
                          padding: WidgetConstant.padding10,
                          child: CircleAPPImageView(application?.icon,
                              radius: 20,
                              onError: (c) => const Icon(Icons.broken_image,
                                  size: APPConst.double40)))),
                ),
              ],
            ),
            Expanded(child: _APPPermissionWidget(state: this))
          ],
        ),
      ),
    );
  }
}

class _APPPermissionWidget extends StatelessWidget {
  const _APPPermissionWidget({required this.state});
  final __Web3APPPermissionViewState state;

  @override
  Widget build(BuildContext context) {
    final application = state.application!;
    return DefaultTabController(
      length: 2,
      child: CustomScrollView(
        slivers: [
          APPSliverAnimatedSwitcher<int>(
              enable: state._selectedIndex,
              widgets: {
                0: (context) => _APPSettingView(state),
                1: (context) => EthereumWeb3PermissionView(
                    key: state.permissionState[1], application: application),
                2: (context) => TronWeb3PermissionView(
                    key: state.permissionState[2], application: application),
                3: (context) => SolanaWeb3PermissionView(
                    key: state.permissionState[3], application: application),
                4: (context) => TonWeb3PermissionView(
                    key: state.permissionState[4], application: application),
                5: (context) => StellarWeb3PermissionView(
                    key: state.permissionState[5], application: application),
                6: (context) => SubstrateWeb3PermissionView(
                    key: state.permissionState[6], application: application),
                7: (context) => AptosWeb3PermissionView(
                    key: state.permissionState[7], application: application),
                8: (context) => SuiWeb3PermissionView(
                    key: state.permissionState[8], application: application),
                9: (context) => CosmosWeb3PermissionView(
                    key: state.permissionState[9], application: application),
                10: (context) => BitcoinWeb3PermissionView(
                    key: state.permissionState[10], application: application)
              }),
          WidgetConstant.sliverPaddingVertial40,
        ],
      ),
    );
  }
}

class _APPSettingView extends StatelessWidget {
  const _APPSettingView(this.state);
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
                initialValue: state.applicationName),
            WidgetConstant.height20,
            AppSwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("web3_activation".tr,
                    style: context.textTheme.titleMedium),
                subtitle: Text("web3_activation_desc".tr),
                maxLine: 3,
                value: state.active,
                onChanged: state.onChangeActivation),
            AppListTile(
              contentPadding: EdgeInsets.zero,
              onTap: state.clearActivities,
              title: Text("remove_activities".tr,
                  style: context.textTheme.titleMedium),
              subtitle: Text("delete_all_activities_desc".tr),
              trailing: Icon(Icons.delete_forever, color: context.colors.error),
            )
          ],
        ),
      ),
    );
  }
}

class Web3ActivityViewItem {
  final String name;
  final Web3AccountAcitvity activity;
  final ReceiptAddress? address;
  final String? url;
  const Web3ActivityViewItem({
    required this.name,
    required this.activity,
    required this.url,
    this.address,
  });
}

mixin Web3PermissionState<
    T extends StatefulWidget,
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    ADDRESS extends NETWORKCHAINACCOUNT<NETWORKADDRESS>,
    CHAINACCOUT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUT,
        WalletNetwork>> on SafeState<T> {
  WEB3CHAIN createNewChainPermission();
  CHAINACCOUT createNewAccountPermission(ADDRESS address, bool defaultAddress);

  WEB3CHAIN getPermission() {
    final WEB3CHAIN newPermission = createNewChainPermission();
    final List<CHAINACCOUT> accounts = [];
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
  List<Web3ActivityViewItem> activities = [];
  Web3APPAuthentication get application;
  NetworkType get type;

  void updateActivities() {
    activities = application.activities
        .where((e) => e.id == chain.network.value)
        .map((e) {
      return Web3ActivityViewItem(
          activity: e,
          address: e.address == null
              ? null
              : chain.getReceiptAddress(e.address!) ??
                  ReceiptAddress(view: e.address!, networkAddress: e),
          name: e.method.camelCase,
          url: e.path);
    }).toList();
  }

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
      final newPrimission =
          createNewAccountPermission(address, chainPermission.isEmpty);
      chainPermission.add(newPrimission);
    }
    if (chainPermission.isNotEmpty &&
        !chainPermission.any((e) => e.defaultAddress)) {
      chainPermission[0].changeDefault(true);
    }

    updateState();
  }

  void onChangeChain(CHAIN? updateChain) {
    chain = updateChain ?? chain;
    updateActivities();
    updateState();
  }

  void updateApplication() {
    final permission = getPermission();
    application.updateChainAccount(permission);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = application.getChainFromNetworkType<WEB3CHAIN>(type,
        allowDisable: true)!;
    final wallet = context.wallet;
    chains = wallet.wallet.getChains().whereType<CHAIN>().toList();
    chain = permission.getCurrentPermissionChain(chains, null);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }
}

class _NavigationRailDestination extends NavigationRailDestination {
  _NavigationRailDestination({required APPImage image, required super.disabled})
      : super(
            label: WidgetConstant.sizedBox,
            icon: Opacity(
                opacity: disabled ? 0.3 : 1,
                child: CircleAssetsImageView(image, radius: 15)));
}
