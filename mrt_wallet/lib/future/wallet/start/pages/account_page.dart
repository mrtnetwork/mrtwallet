import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/bch/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/account/pages/account.dart';
import 'package:mrt_wallet/future/wallet/network/monero/monero.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/solana/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/sui/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/ton/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/tron/account/account.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'account_not_adress.dart';
import 'appbar.dart';
import 'client.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'platform_widgets/widgets.dart';

class NetworkAccountPageView extends StatelessWidget {
  const NetworkAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    final chainAccount = wallet.wallet.chain;

    return Scaffold(
      bottomNavigationBar: _BottomAppBar(wallet),
      body: LiveWidget(() {
        final chainStatus =
            NetworkClientConnectionSliverHeaderDelegate.detectStatus(
                chainAccount);
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
              return NoAccountFoundInChainWidget(chainAccount);
            }
            return IgnorePointer(
              ignoring: chainStatus == AccountPageAppbarStatus.provider,
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
  final Chain chainAccount;

  @override
  Widget build(BuildContext context) {
    final network = chainAccount.network;
    switch (network.type) {
      case NetworkType.bitcoinCash:
        return BitcoinCashAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.bitcoinAndForked:
        return BitcoinAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.xrpl:
        return RippleAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.solana:
        return SolanaAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.monero:
        return MoneroAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.stellar:
        return StellarAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.ethereum:
        return ETHAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.tron:
        return TronAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.cardano:
        return CardanoAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.ton:
        return TonAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.substrate:
        return SubstrateAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.cosmos:
        return CosmosAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.sui:
        return SuiAccountPageView(chainAccount: chainAccount.cast());
      case NetworkType.aptos:
        return AptosAccountPageView(chainAccount: chainAccount.cast());
      default:
        return const TabBarView(
            physics: WidgetConstant.noScrollPhysics, children: []);
    }
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar(this.wallet);
  final WalletProvider wallet;

  final FloatingActionButtonLocation fabLocation =
      FloatingActionButtonLocation.endDocked;

  @override
  Widget build(BuildContext context) {
    // final wallet = context.watch<WalletProvider>(StateConst.main);
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
                  icon: const Icon(Icons.switch_account_sharp),
                  tooltip: "switch_address".tr,
                  onPressed: () {
                    final account = wallet.wallet.chain;
                    context
                        .openSliverBottomSheet<ChainAccount>(
                      "switch_account".tr,
                      child: SwitchOrSelectAccountView(
                        account: account,
                        showMultiSig: true,
                        isSwitch: true,
                      ),
                      centerContent: false,
                      appbarActions: (c) => [
                        Padding(
                          padding: WidgetConstant.paddingHorizontal10,
                          child: IconButton(
                              onPressed: () {
                                c.to(PageRouter.setupGenericAddress,
                                    argruments: account);
                              },
                              icon: const Icon(Icons.add_box),
                              tooltip: "new_address".tr),
                        )
                      ],
                    )
                        .then((e) {
                      if (e == null) return;
                      wallet.wallet.switchAccount(account: account, address: e);
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: "lock_wallet".tr,
                  icon: wallet.wallet.isUnlock
                      ? const Icon(Icons.lock_open)
                      : const Icon(Icons.lock),
                  onPressed: () {
                    if (wallet.wallet.isUnlock) {
                      wallet.wallet.lock();
                    } else {
                      context.openDialogPage(
                        "",
                        child: (c) {
                          return PasswordCheckerView(
                            title: "unlock_wallet".tr,
                            accsess: WalletAccsessType.unlock,
                            onWalletAccess: (password) async {
                              return null;
                            },
                          );
                        },
                      );
                    }
                  },
                ),
                SelectProviderIcon(key: UniqueKey()),
                IconButton(
                    tooltip: "switch_network".tr,
                    onPressed: () async {
                      await context
                          .openDialogPage(
                        "switch_network".tr,
                        fullWidget: SwitchNetworkView(
                          selectedNetwork: wallet.wallet.network,
                        ),
                      )
                          .then(
                        (value) {
                          if (value == null) return;
                          if (value is int) {
                            wallet.wallet.switchNetwork(value);
                          } else {
                            context.mybeTo(PageRouter.importNetwork(value));
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.account_tree_sharp)),
                ...bottomAppBarWidgets(context),
              ],
            )
          ],
        ),
      ),
    );
  }
}
