import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/models/models/block_info.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateQuickAccessView extends StatelessWidget {
  const SubstrateQuickAccessView(
      {this.scrollController, this.chain, super.key});
  final ScrollController? scrollController;
  final SubstrateChain? chain;
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SubstrateChain>(
      account: chain,
      allowEmptyAccount: true,
      clientRequired: true,
      childBulder: (wallet, chain, onAccountChanged) {
        return _QuickAccessView(
            scrollController: scrollController, account: chain);
      },
    );
  }
}

class _QuickAccessView extends StatefulWidget {
  const _QuickAccessView({this.scrollController, required this.account});
  final ScrollController? scrollController;
  final SubstrateChain account;

  @override
  State<_QuickAccessView> createState() => __QuickAccessViewState();
}

class __QuickAccessViewState extends SubstrateAccountState<_QuickAccessView> {
  @override
  SubstrateChain get account => widget.account;

  SubstrateChainMetadata get api => account.client.metadata;
  StorageInfo? accountInfoKey;
  late final Future<SubstrateBlockWithEra> finalizeBlock =
      account.client.finalizeBlockWithEra();

  @override
  void onInitOnce() {
    super.onInitOnce();
    accountInfoKey = api.getAccountInfoStorageKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("substrate_quick_block_access".tr)),
      body: UnfocusableChild(
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                sliver: SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        APPFutureBuilder(
                            onData: (context, result) {
                              return Column(
                                children: [
                                  CopyableTextWidget(
                                      text: result.block,
                                      widget: AppListTile(
                                          subtitle: Text(result.block),
                                          title: Text("finaliz_block".tr,
                                              style: context
                                                  .textTheme.titleMedium))),
                                  CopyableTextWidget(
                                      text: result.era.toString(),
                                      widget: AppListTile(
                                          subtitle: Text(result.era.toString()),
                                          title: Text("quick_era".tr,
                                              style: context
                                                  .textTheme.titleMedium)))
                                ],
                              );
                            },
                            onError: (context, err) {
                              return AppListTile(
                                  title: Text("finaliz_block_era".tr),
                                  trailing: Tooltip(
                                      message: err.toString(),
                                      child: WidgetConstant.errorIcon));
                            },
                            onProgress: (context) {
                              return AppListTile(
                                  title: Text("finaliz_block_era".tr),
                                  trailing:
                                      const APPCircularProgressIndicator());
                            },
                            future: finalizeBlock),
                        CopyableTextWidget(
                            text: api.genesis,
                            widget: AppListTile(
                                subtitle: Text(api.genesis),
                                title: Text("genesis_hash".tr,
                                    style: context.textTheme.titleMedium))),
                      ]),
                ))
          ],
        ),
      ),
    );
  }
}
