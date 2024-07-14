import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';

class SwitchNetworkView extends StatefulWidget {
  const SwitchNetworkView({required this.selectedNetwork, super.key});
  final WalletNetwork selectedNetwork;

  @override
  State<SwitchNetworkView> createState() => _SwitchNetworkViewState();
}

class _SwitchNetworkViewState extends State<SwitchNetworkView>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 10, vsync: this);
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  double? height;
  void onChangeSize(Size size) {
    if (size.height != height) {
      height = size.height;
      setState(() {});
    }
  }

  late List<ChainHandler> bitcoinNetworks;
  late List<ChainHandler> rippleNetworks;
  late List<ChainHandler> evmNetworks;
  late List<ChainHandler> tvmNetworks;
  late List<ChainHandler> solNetworks;
  late List<ChainHandler> cardanoNetworks;
  late List<ChainHandler> cosmosNetworks;
  late List<ChainHandler> tonNetworks;
  late List<ChainHandler> polkadotNetworks;
  late List<ChainHandler> kusamaNetworks;

  void initNetwork() {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final networks = wallet.getChains();
    int initialIndex;
    bitcoinNetworks = networks
        .where((element) =>
            (element.network.type == NetworkType.bitcoinAndForked ||
                element.network.type == NetworkType.bitcoinCash))
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    rippleNetworks = networks
        .where((element) => element.network.type == NetworkType.xrpl)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    evmNetworks = networks
        .where((element) => element.network.type == NetworkType.ethereum)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    tvmNetworks = networks
        .where((element) => element.network.type == NetworkType.tron)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    solNetworks = networks
        .where((element) => element.network.type == NetworkType.solana)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    cardanoNetworks = networks
        .where((element) => element.network.type == NetworkType.cardano)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    cosmosNetworks = networks
        .where((element) => element.network.type == NetworkType.cosmos)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    tonNetworks = networks
        .where((element) => element.network.type == NetworkType.ton)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    polkadotNetworks = networks
        .where((element) => element.network.type == NetworkType.polkadot)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    kusamaNetworks = networks
        .where((element) => element.network.type == NetworkType.kusama)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));

    final currentNetwork = MethodUtils.nullOnException(() =>
        networks.firstWhere((element) =>
            element.network.value == widget.selectedNetwork.value));
    switch (currentNetwork?.network.type) {
      case NetworkType.xrpl:
        initialIndex = 1;
        break;
      case NetworkType.ethereum:
        initialIndex = 2;
        break;
      case NetworkType.tron:
        initialIndex = 3;
        break;
      case NetworkType.solana:
        initialIndex = 4;
        break;
      case NetworkType.cardano:
        initialIndex = 5;
        break;
      case NetworkType.cosmos:
        initialIndex = 6;
        break;
      case NetworkType.ton:
        initialIndex = 7;
        break;
      case NetworkType.polkadot:
        initialIndex = 8;
        break;
      case NetworkType.kusama:
        initialIndex = 9;
        break;
      default:
        initialIndex = 0;
        break;
    }
    if (initialIndex != 0) {
      tabController.animateTo(initialIndex);
    }
    progressKey.backToIdle();
  }

  bool showImport = false;

  void tabListener() {
    if (tabController.index == 2 && !showImport) {
      setState(() {
        showImport = true;
      });
    } else if (tabController.index != 2 && showImport) {
      setState(() {
        showImport = false;
      });
    }
  }

  @override
  void initState() {
    tabController.addListener(tabListener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MethodUtils.after(() async => initNetwork());
  }

  @override
  void dispose() {
    tabController.removeListener(tabListener);
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstraintsBoxView(
        alignment: Alignment.center,
        maxWidth: APPConst.dialogWidth,
        padding: WidgetConstant.padding20,
        child: ClipRRect(
          borderRadius: WidgetConstant.border8,
          child: Material(
            color: context.colors.surface,
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverAppBar(
                  title: Text("switch_network".tr),
                  leading: const SizedBox(),
                  leadingWidth: 0,
                  bottom: TabBar(
                      controller: tabController,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      tabs: const [
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.btc,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.xrp,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.eth,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.trx,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.sol,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.ada,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.atom,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.ton,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.polkadot,
                                radius: 15)),
                        Tab(
                            icon: CircleAssetsImgaeView(APPConst.kusama,
                                radius: 15)),
                      ]),
                  pinned: true,
                  actions: [
                    APPAnimatedSwitcher(
                        duration: APPConst.animationDuraion,
                        enable: showImport,
                        widgets: {
                          true: (c) => IconButton(
                              tooltip: "import".tr,
                              onPressed: () {
                                context.pop(-1);
                              },
                              icon: const Icon(Icons.add)),
                          false: (c) => WidgetConstant.sizedBox
                        }),
                    const CloseButton(),
                  ],
                ),
                SliverToBoxAdapter(
                  child: ConstraintsBoxView(
                    maxHeight: 400,
                    // padding: WidgetConstant.paddingHorizontal10,
                    child: PageProgress(
                      backToIdle: APPConst.milliseconds100,
                      initialStatus: StreamWidgetStatus.progress,
                      key: progressKey,
                      child: () =>
                          TabBarView(controller: tabController, children: [
                        _NetworksView(widget.selectedNetwork, bitcoinNetworks),
                        _NetworksView(widget.selectedNetwork, rippleNetworks),
                        _NetworksView(widget.selectedNetwork, evmNetworks),
                        _NetworksView(widget.selectedNetwork, tvmNetworks),
                        _NetworksView(widget.selectedNetwork, solNetworks),
                        _NetworksView(widget.selectedNetwork, cardanoNetworks),
                        _NetworksView(widget.selectedNetwork, cosmosNetworks),
                        _NetworksView(widget.selectedNetwork, tonNetworks),
                        _NetworksView(widget.selectedNetwork, polkadotNetworks),
                        _NetworksView(widget.selectedNetwork, kusamaNetworks)
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworksView extends StatelessWidget {
  const _NetworksView(this.selected, this.networks);
  final WalletNetwork selected;
  final List<ChainHandler> networks;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final len = networks.length;
        final lastIndex = index + 1 == len;
        final net = networks[index].network;
        final balance = networks[index].account.totalBalance.value;
        return Padding(
          padding: WidgetConstant.paddingHorizontal20,
          child: Column(
            children: [
              InkWell(
                borderRadius: WidgetConstant.border8,
                onTap: selected == net
                    ? null
                    : () {
                        context.pop(net.value);
                      },
                child: Padding(
                  padding: WidgetConstant.padding5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleTokenImgaeView(net.coinParam.token, radius: 20),
                          WidgetConstant.width8,
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(net.coinParam.token.symbol,
                                  style: context.textTheme.labelLarge),
                              OneLineTextWidget(net.coinParam.token.name),
                              CoinPriceView(
                                  token: net.coinParam.token, balance: balance),
                            ],
                          )),
                          WidgetConstant.width8,
                          if (selected == net) const Icon(Icons.check_circle)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!lastIndex) const Divider()
            ],
          ),
        );
      },
      itemCount: networks.length,
    );
  }
}
