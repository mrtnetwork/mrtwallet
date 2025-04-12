import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/http/impl/impl.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/api/client/networks/cosmos/cosmos.dart';

import 'package:mrt_wallet/wallet/models/models.dart';

typedef ONIBCSELECTDESTINATIONCHAIN = void Function(
    BuildContext context, CosmosIbcChainData chain);

class CosmosIbcTransactionPickDestinationChainView extends StatefulWidget {
  final ScrollController scrollController;
  final ONIBCSELECTDESTINATIONCHAIN onSelectChain;
  final CosmosChain currentChain;
  const CosmosIbcTransactionPickDestinationChainView(
      {required this.scrollController,
      required this.onSelectChain,
      required this.currentChain,
      super.key});

  @override
  State<CosmosIbcTransactionPickDestinationChainView> createState() =>
      _CosmosTransactionPickTokenViewState();
}

class _CosmosTransactionPickTokenViewState
    extends State<CosmosIbcTransactionPickDestinationChainView>
    with
        SafeState<CosmosIbcTransactionPickDestinationChainView>,
        ProgressMixin,
        HttpImpl,
        CosmosCustomRequest {
  List<CosmosChain> chains = [];
  List<CW20Token> tokens = [];

  Future<void> onSelectChain(CW20Token token) async {
    progressKey.progressText("ibc_retrieval_requirements".tr);
    final chain = chains[tokens.indexOf(token)];
    final String? chainRegistery = chain.network.coinParam.chainRegisteryName;
    final ccr = await MethodUtils.call(
        () => getChainData(chainRegistery!,
            chainType: chain.network.coinParam.chainType),
        delay: chainRegistery == null ? APPConst.oneSecoundDuration : null);
    final ccrChain = ccr.resultOrNull;
    final currentChainName =
        widget.currentChain.network.coinParam.chainRegisteryName;
    List<CCRIbcTransition> ibcs = [];

    if (ccrChain != null && currentChainName != null) {
      for (final i in ccrChain.$1.assetList.assets) {
        ibcs.addAll(i.traces
            .whereType<CCRIbcTransition>()
            .toList()
            .where((e) => e.counterparty.chainName == currentChainName)
            .toList());
      }
    }
    CosmosIbcChainData ibcChain = CosmosIbcChainData(
        ccrChainData: ccrChain?.$1, chain: chain, ibcConnections: ibcs);

    progressKey.success(backToIdle: false);
    if (context.mounted) {
      widget.onSelectChain(context, ibcChain);
    }
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    final provider = context.watch<WalletProvider>(StateConst.main);
    chains = provider.wallet
        .getChains<CosmosChain>()
        .where((e) =>
            e != widget.currentChain &&
            e.network.coinParam.chainType ==
                widget.currentChain.network.coinParam.chainType)
        .toList();
    tokens = chains.map((e) => e.network.coinParam.nativeToken).toList();
  }

  @override
  void safeDispose() {
    super.safeDispose();
    for (final i in tokens) {
      i.balance.dispose();
    }
    tokens = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cosmos_chains'.tr),
      ),
      body: PageProgress(
        key: progressKey,
        backToIdle: APPConst.oneSecoundDuration,
        child: (context) => CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverConstraintsBoxView(
              padding: WidgetConstant.paddingHorizontal20,
              sliver: SliverMainAxisGroup(slivers: [
                SliverToBoxAdapter(
                    child: PageTitleSubtitle(
                        title: 'destination_chain'.tr,
                        body: Text("cosmos_destination_chain_dest".tr))),
                SliverList.separated(
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      return TokenDetailsView(
                        onSelect: () => onSelectChain(token),
                        onSelectIcon: WidgetConstant.sizedBox,
                        token: token,
                        showBalance: false,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return WidgetConstant.divider;
                    },
                    itemCount: tokens.length)
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
