import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SwitchNetworkView extends StatefulWidget {
  const SwitchNetworkView({required this.selectedNetwork, super.key});
  final AppNetworkImpl selectedNetwork;

  @override
  State<SwitchNetworkView> createState() => _SwitchNetworkViewState();
}

class _SwitchNetworkViewState extends State<SwitchNetworkView>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 7, vsync: this);

  double? height;
  void onChangeSize(Size size) {
    if (size.height != height) {
      height = size.height;
      setState(() {});
    }
  }

  late List<AppChain> bitcoinNetworks;
  late List<AppChain> rippleNetworks;
  late List<AppChain> evmNetworks;
  late List<AppChain> tvmNetworks;
  late List<AppChain> solNetworks;
  late List<AppChain> cardanoNetworks;
  late List<AppChain> cosmosNetworks;

  void initNetwork() {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final networks = wallet.getChains();
    int initialIndex = 0;
    bitcoinNetworks = networks
        .where((element) => element.network is AppBitcoinNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    rippleNetworks = networks
        .where((element) => element.network is AppXRPNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    evmNetworks = networks
        .where((element) => element.network is APPEVMNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    tvmNetworks = networks
        .where((element) => element.network is APPTVMNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    solNetworks = networks
        .where((element) => element.network is APPSolanaNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    cardanoNetworks = networks
        .where((element) => element.network is APPCardanoNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    cosmosNetworks = networks
        .where((element) => element.network is APPCosmosNetwork)
        .toList()
      ..sort((a, b) => a.network.value.compareTo(b.network.value));
    final currentNetwork = MethodCaller.nullOnException(() =>
        networks.firstWhere((element) =>
            element.network.value == widget.selectedNetwork.value));
    if (currentNetwork != null) {
      if (currentNetwork.network is AppXRPNetwork) {
        initialIndex = 1;
      } else if (currentNetwork.network is APPEVMNetwork) {
        initialIndex = 2;
      } else if (currentNetwork.network is APPTVMNetwork) {
        initialIndex = 3;
      } else if (currentNetwork.network is APPSolanaNetwork) {
        initialIndex = 4;
      } else if (currentNetwork.network is APPCardanoNetwork) {
        initialIndex = 5;
      } else if (currentNetwork.network is APPCosmosNetwork) {
        initialIndex = 6;
      }
    }
    if (initialIndex != 0) {
      tabController.animateTo(initialIndex);
    }
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
    initNetwork();
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
        maxWidth: AppGlobalConst.dialogWidth,
        padding: WidgetConstant.padding20,
        child: ClipRRect(
          borderRadius: WidgetConstant.border8,
          child: Material(
            color: context.colors.background,
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
                      tabs: [
                        Tab(text: "bitcoin_and_forked".tr),
                        Tab(text: "ripple".tr),
                        Tab(text: "evm_networks".tr),
                        Tab(text: "tvm_networks".tr),
                        Tab(text: "sol_networks".tr),
                        Tab(text: "cardano_networks".tr),
                        Tab(text: "cosmos_networks".tr),
                      ]),
                  pinned: true,
                  actions: [
                    AnimatedSwitcher(
                      duration: AppGlobalConst.animationDuraion,
                      child: showImport
                          ? FilledButton(
                              onPressed: () {
                                context.pop(-1);
                              },
                              child: Text("import".tr))
                          : WidgetConstant.sizedBox,
                    ),
                    const CloseButton(),
                  ],
                ),
                SliverToBoxAdapter(
                  child: ConstraintsBoxView(
                    maxHeight: 400,
                    child: TabBarView(controller: tabController, children: [
                      _NetworksView(widget.selectedNetwork, bitcoinNetworks),
                      _NetworksView(widget.selectedNetwork, rippleNetworks),
                      _NetworksView(widget.selectedNetwork, evmNetworks),
                      _NetworksView(widget.selectedNetwork, tvmNetworks),
                      _NetworksView(widget.selectedNetwork, solNetworks),
                      _NetworksView(widget.selectedNetwork, cardanoNetworks),
                      _NetworksView(widget.selectedNetwork, cosmosNetworks)
                    ]),
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
  final AppNetworkImpl selected;
  final List<AppChain> networks;
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
