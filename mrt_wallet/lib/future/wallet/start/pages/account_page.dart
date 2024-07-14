import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bch/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/account/pages/account.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/solana/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/ton/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/account/account.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';
import 'appbar.dart';
import 'client.dart';

class NetworkAccountPageView extends StatelessWidget {
  const NetworkAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    final chainAccount = wallet.chain;
    return Scaffold(
      bottomNavigationBar: _BottomAppBar(wallet),
      body: LiveWidget(() {
        final status = wallet.chain.provider()?.status.value;
        final bool isConnect = !(status?.isConnect ?? false);
        return DefaultTabController(
          length: chainAccount.services.length,
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
            if (!chainAccount.haveAddress) return [];
            return [
              NetworkClientConnectionSliverHeaderDelegate(wallet),
              SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                      pinned: true,
                      key: UniqueKey(),
                      delegate: AccountPageSliverHeaderDelegate(wallet))),
            ];
          }, body: Builder(builder: (context) {
            if (!chainAccount.haveAddress) {
              return Padding(
                  padding: WidgetConstant.padding20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PageTitleSubtitle(
                        title: "setup_network_address".tr.replaceOne(
                            chainAccount.network.coinParam.token.name),
                        body: Text("setup_network_address_desc".tr.replaceOne(
                            chainAccount.network.coinParam.token.name)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FixedElevatedButton(
                              padding: WidgetConstant.paddingVertical20,
                              onPressed: () {
                                context.to(PageRouter.setupGenericAddress,
                                    argruments: wallet.chain.account);
                              },
                              child: Text("setup_address".tr)),
                        ],
                      )
                    ],
                  ));
            }
            return IgnorePointer(
              ignoring: isConnect,
              child: _AccountPageView(chainAccount),
            );
          })),
        );
      }),
    );
  }
}

class _AccountPageView extends StatelessWidget {
  const _AccountPageView(this.chainAccount);
  final ChainHandler chainAccount;

  @override
  Widget build(BuildContext context) {
    final network = chainAccount.network;
    switch (network.type) {
      case NetworkType.bitcoinCash:
        return BitcoinCashAccountPageView(chainAccount: chainAccount);
      case NetworkType.bitcoinAndForked:
        return BitcoinAccountPageView(chainAccount: chainAccount);
      case NetworkType.xrpl:
        return RippleAccountPageView(chainAccount: chainAccount);
      case NetworkType.solana:
        return SolanaAccountPageView(chainAccount: chainAccount);
      case NetworkType.ethereum:
        return ETHAccountPageView(chainAccount: chainAccount);
      case NetworkType.tron:
        return TronAccountPageView(chainAccount: chainAccount);
      case NetworkType.cardano:
        return CardanoAccountPageView(chainAccount: chainAccount);
      case NetworkType.ton:
        return TonAccountPageView(chainAccount: chainAccount);
      case NetworkType.polkadot:
      case NetworkType.kusama:
        return SubstrateAccountPageView(chainAccount: chainAccount);
      case NetworkType.cosmos:
        return CosmosAccountPageView(chainAccount: chainAccount);
      default:
        return const TabBarView(children: []);
    }
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar(this.model);
  final WalletProvider model;

  final FloatingActionButtonLocation fabLocation =
      FloatingActionButtonLocation.endDocked;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return BottomAppBar(
      color: context.colors.primary,
      child: IconTheme(
        data: IconThemeData(color: context.colors.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh_sharp),
                  tooltip: "switch_address".tr,
                  onPressed: () {
                    context
                        .openSliverBottomSheet<CryptoAddress>(
                          "switch_account".tr,
                          child: SwitchOrSelectAccountView(
                            account: wallet.chain.account,
                            showMultiSig: true,
                          ),
                          centerContent: false,
                          appbarActions: [
                            Padding(
                              padding: WidgetConstant.paddingHorizontal10,
                              child: IconButton(
                                  onPressed: () {
                                    context.to(PageRouter.setupGenericAddress,
                                        argruments: wallet.chain.account);
                                  },
                                  icon: const Icon(Icons.add_box),
                                  tooltip: "new_address".tr),
                            )
                          ],
                          minExtent: 0.5,
                          maxExtend: 0.9,
                          initialExtend: 0.7,
                        )
                        .then(wallet.switchAccount);
                  },
                ),
              ],
            ),
            Row(
              children: [
                if (model.wallet.requiredPassword)
                  IconButton(
                    tooltip: "lock_wallet".tr,
                    icon: const Icon(Icons.lock),
                    onPressed: () {
                      model.lock();
                    },
                  ),
                SelectProviderIcon(key: UniqueKey()),
                IconButton(
                    tooltip: "switch_network".tr,
                    onPressed: () async {
                      context
                          .openDialogPage<int>(
                        "switch_network".tr,
                        fullWidget: SwitchNetworkView(
                          selectedNetwork: model.network,
                        ),
                      )
                          .then(
                        (value) {
                          if (value == null) return;
                          if (value.isNegative) {
                            context.to(PageRouter.importEthereumNetwork);
                          } else {
                            model.switchNetwork(value);
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.account_tree_sharp)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
