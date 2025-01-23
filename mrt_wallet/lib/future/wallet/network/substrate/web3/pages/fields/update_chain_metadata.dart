import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SubstrateWeb3UpdateChainMetadataRequestView extends StatelessWidget {
  const SubstrateWeb3UpdateChainMetadataRequestView(
      {required this.request, super.key});
  final Web3SubstrateAddNewChainForm request;
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<Web3SubstrateGlobalRequestController>(
        request.request.info.request.requestId);
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: PageTitleSubtitle(
            title: "update_metadata".tr,
            body: Text('substrate_update_metadata_desc'.tr)),
      ),
      SubstrateAddChainInfoView(
          onAddChain: controller.updateNetworkMetadata,
          network: request.chain!.network.coinParam,
          buttonText: "update_metadata".tr),
    ]);
  }
}
