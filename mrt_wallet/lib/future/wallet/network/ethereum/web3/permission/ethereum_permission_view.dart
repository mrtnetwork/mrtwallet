import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ethereum/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/etherum.dart';

class EthereumWeb3PermissionView extends StatefulWidget {
  const EthereumWeb3PermissionView(
      {required this.permission,
      required this.onUpdateChainPermission,
      Key? key})
      : super(key: key);
  final Web3EthereumChain? permission;
  final OnUpdateChainPermission onUpdateChainPermission;

  @override
  State<EthereumWeb3PermissionView> createState() =>
      _EthereumWeb3PermissionViewState();
}

class _EthereumWeb3PermissionViewState extends State<EthereumWeb3PermissionView>
    with SafeState {
  late BigInt currentChain = permission.currentChain;
  late Web3EthereumChain permission =
      widget.permission ?? Web3EthereumChain.create();

  late final List<EthereumChain> chains;
  Map<EthereumChain, List<Web3EthereumChainAccount>> permissions = {};
  late EthereumChain chain;

  Web3EthereumChainAccount? accountPermission(IEthAddress address) {
    return permissions[chain]!.firstWhereOrNull(
        (e) => e.address.address == address.networkAddress.address);
  }

  bool hasPermission(IEthAddress address) {
    final contains = accountPermission(address) != null;
    return contains;
  }

  void addAccount(IEthAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.remove(exists);
    } else {
      permissions[chain]?.add(Web3EthereumChainAccount.fromChainAccount(
          address: address, chainId: chain.chainId));
    }
    updateState();
  }

  void onChangeCurrentChain(EthereumChain? chain) {
    currentChain = chain?.chainId ?? currentChain;
    updateState();
  }

  void onChangeChain(EthereumChain? updateChain) {
    chain = updateChain ?? chain;
    updateState();
  }

  void complete() {
    final accounts = permissions.values.expand((e) => e).toList();
    final newPermission = Web3EthereumChain.create(chainId: currentChain);
    newPermission.updateChainAccount(accounts);
    widget.onUpdateChainPermission(newPermission);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<EthereumChain>().toList();
    for (final i in chains) {
      permissions[i] = permission.accounts
          .where((e) => e.chainId == i.network.coinParam.chainId)
          .toList();
    }
    chain = chains.firstWhere((e) => e.chainId == currentChain);
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("active_chain".tr, style: context.textTheme.titleMedium),
          Text("web3_switch_chain_desc".tr,
              style: context.textTheme.bodyMedium),
          WidgetConstant.height8,
          AppDropDownBottom(
              label: "network".tr,
              items: {
                for (final i in chains) i: Text(i.network.coinParam.token.name)
              },
              onChanged: onChangeCurrentChain,
              value: chain),
          WidgetConstant.height20,
          Text("ethereum_networks".tr, style: context.textTheme.titleMedium),
          Text("evm_account_permission_desc".tr),
          WidgetConstant.height8,
          AppDropDownBottom(
              label: "network".tr,
              items: {
                for (final i in chains) i: Text(i.network.coinParam.token.name)
              },
              onChanged: onChangeChain,
              value: chain),
          WidgetConstant.height20,
          Text("accounts".tr, style: context.textTheme.titleMedium),
          Text("web3_accounts_permission_desc".tr),
          WidgetConstant.height8,
          APPAnimatedSwitcher(enable: chain.haveAddress, widgets: {
            true: (c) => Column(
                  children: [
                    ListView.builder(
                        addAutomaticKeepAlives: false,
                        shrinkWrap: true,
                        physics: WidgetConstant.noScrollPhysics,
                        itemBuilder: (c, index) {
                          final addr = chain.addresses[index];

                          return ContainerWithBorder(
                            onRemove: () {
                              addAccount(addr);
                            },
                            onRemoveWidget: IgnorePointer(
                                child: Checkbox(
                                    value: hasPermission(addr),
                                    onChanged: (e) {})),
                            child: AddressDetailsView(address: addr),
                          );
                        },
                        itemCount: chain.addresses.length),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                            padding: WidgetConstant.paddingVertical40,
                            child: Text("update_permission".tr),
                            onPressed: () {
                              complete();
                            }),
                      ],
                    )
                  ],
                ),
            false: (c) => NoAccountFoundInChainWidget(chain)
          }),
        ],
      ),
    );
  }
}
