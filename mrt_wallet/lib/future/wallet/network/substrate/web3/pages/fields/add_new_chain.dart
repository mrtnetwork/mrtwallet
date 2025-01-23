import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/network/import_chain.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/controller/controller/global.dart';
import 'package:mrt_wallet/future/widgets/widgets/alarm.dart';
import 'package:mrt_wallet/future/widgets/widgets/animated/widgets/animated_switcher.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class SubstrateWeb3AddNewChainRequestView extends StatefulWidget {
  const SubstrateWeb3AddNewChainRequestView({required this.request, super.key});
  final Web3SubstrateAddNewChainForm request;
  @override
  State<SubstrateWeb3AddNewChainRequestView> createState() =>
      _SubstrateWeb3AddNewChainRequestViewState();
}

class _SubstrateWeb3AddNewChainRequestViewState
    extends State<SubstrateWeb3AddNewChainRequestView>
    with
        SafeState<SubstrateWeb3AddNewChainRequestView>,
        AddSubstrateChainState<SubstrateWeb3AddNewChainRequestView> {
  Web3SubstrateAddNewChainForm get request => widget.request;
  Web3SubstrateAddNewChain get params => request.params;

  @override
  Future<void> addOrUpdateChain() async {
    final controller = context.watch<Web3SubstrateGlobalRequestController>(
        request.request.info.request.requestId);
    controller.importNewChain();
  }

  @override
  Future<void> checkNetwork() async {
    final controller = context.watch<Web3SubstrateGlobalRequestController>(
        request.request.info.request.requestId);
    if (!(formKey.currentState?.validate() ?? false)) return;
    uri = rpcKey.currentState?.getEndpoint();
    if (uri == null) return;
    controller.checkNetwork(
        networkName: networkName,
        symbol: symbol,
        decimal: decimal,
        uri: uri!,
        explorerAddressLink: explorerAddressLink.nullOnEmpty,
        explorerTransaction: explorerTransaction.nullOnEmpty);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    final controller = context.watch<Web3SubstrateGlobalRequestController>(
        request.request.info.request.requestId);
    network = controller.newNetwork;
    metadata = controller.newMetadata;
    decimal = network?.token.decimal ?? params.tokenDecimals;
    symbol = network?.token.symbol ?? params.tokenSymbol;
    networkName = network?.token.name ?? params.chain;
    explorerAddressLink = network?.addressExplorer ?? '';
    explorerTransaction = network?.transactionExplorer ?? '';
    final provider = network?.providers.elementAt(0);
    if (provider != null) {
      uri = RPCURL(url: provider.callUrl, auth: provider.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: APPSliverAnimatedSwitcher(enable: network != null, widgets: {
        false: (context) => SubstrateAddChainFieldsView(state: this),
        true: (context) => SliverMainAxisGroup(slivers: [
              SliverToBoxAdapter(
                  child: AlarmTextContainer(
                      message: "network_enable_web3_desc".tr)),
              SubstrateAddChainInfoView(
                  onAddChain: addOrUpdateChain,
                  network: network!,
                  metadata: metadata!),
            ])
      }),
    );
  }
}
