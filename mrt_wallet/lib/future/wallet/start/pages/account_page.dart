import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPConst, CoinGeckoUtils, QuickContextAccsess, Translate, UriUtils;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/account/pages/show_public_key.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bch/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/ethereum/account/pages/account.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/solana/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/ton/account/account.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/account/account.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart' show IntVoid;
import 'package:mrt_wallet/wallet/wallet.dart'
    show WalletBitcoinCashNetwork, ChainHandler, CryptoAddress, NetworkType;
import 'package:mrt_wallet/future/router/page_router.dart';

class NetworkAccountPageView extends StatelessWidget {
  const NetworkAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    final chainAccount = wallet.chain;
    return DefaultTabController(
      length: chainAccount.services.length,
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            if (!chainAccount.haveAddress) return [];

            return [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: SizedBox(
                    height: 80,
                    child: _AddressDetailsView(
                      account: chainAccount.account.address,
                      onPressed: (p0) {
                        switch (p0) {
                          case 1:
                            context.openSliverBottomSheet(
                              "publick_key".tr,
                              child: AccountPublicKeyView(
                                  chainAccount: wallet.chain),
                            );

                            break;
                          case 0:
                            context.to(PageRouter.exportPrivateKey,
                                argruments: chainAccount.account.address);
                            break;
                          case 2:
                            context.to(PageRouter.removeAccount,
                                argruments: chainAccount.account.address);
                          case 3:
                            context
                                .openSliverBottomSheet<String>(
                                  "account_name".tr,
                                  child: StringWriterView(
                                    defaultValue: chainAccount
                                        .account.address.accountName,
                                    regExp: APPConst.accountNameRegExp,
                                    title: PageTitleSubtitle(
                                        title:
                                            "setup_or_update_account_name".tr,
                                        body: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("setup_or_update_account_name"
                                                .tr),
                                            WidgetConstant.height8,
                                            Text("remove_account_name_desc".tr),
                                          ],
                                        )),
                                    buttomText: "setup_input".tr,
                                    label: "account_name".tr,
                                  ),
                                )
                                .then((value) => wallet.setupAccountName(
                                    value, chainAccount.account.address));

                          default:
                        }
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: context.mediaQuery.size.width,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: WidgetConstant.padding20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                CircleTokenImgaeView(
                                    chainAccount.network.coinParam.token,
                                    radius: 40),
                                WidgetConstant.height8,
                                Text(chainAccount.network.coinParam.token.name,
                                    style: context.textTheme.labelLarge),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CoinPriceView(
                                    account: chainAccount.account.address,
                                    style: context.textTheme.titleLarge,
                                    token: chainAccount.network.coinParam.token,
                                  ),
                                  WidgetConstant.height8,
                                  _AccountButtons(chainAccount)
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _TabbarView(chainAccount),
              ),
              SliverAppBar(
                pinned: true,
                toolbarHeight: 0,
                bottom: _NetworkPageTabbar(
                    chainAccount: chainAccount,
                    child: const TabBar(tabs: [Tab(text: "")])),
              ),
            ];
          },
          body: !wallet.chain.haveAddress
              ? Padding(
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
                                context.to(
                                    PageRouter.setupAddressPage(
                                        chainAccount.network),
                                    argruments: chainAccount.account);
                              },
                              child: Text("setup_address".tr)),
                        ],
                      )
                    ],
                  ))
              : _AccountPage(chainAccount)),
    );
  }
}

class _TabbarView extends StatelessWidget {
  const _TabbarView(this.chainAccount);
  final ChainHandler chainAccount;

  @override
  Widget build(BuildContext context) {
    final hasProvider = chainAccount.provider() != null;
    final networkParam = chainAccount.network.coinParam;
    return Column(
      children: [
        if (!hasProvider)
          InkWell(
            child: MaterialBanner(
              backgroundColor: context.colors.errorContainer,
              padding: WidgetConstant.padding10,
              content: Text(
                "network_no_provider_detected".tr,
                style: context.textTheme.titleMedium
                    ?.copyWith(color: context.colors.onErrorContainer),
              ),
              actions: [
                SelectProviderIcon(
                    icon: Icon(Icons.add_box,
                        color: context.colors.onErrorContainer)),
              ],
            ),
          ),
        if (networkParam.hasAccountExplorer)
          AppListTile(
            title: Text("view_on_explorer".tr),
            subtitle: Text("view_address_on_explorer".tr),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              UriUtils.lunch(networkParam.getAccountExplorer(
                  chainAccount.account.address.address.toAddress));
            },
          ),
        if (networkParam.hasMarketUrl)
          AppListTile(
            title: const Text("CoinGecko"),
            subtitle: Text("view_on_coingecko"
                .tr
                .replaceOne(chainAccount.network.coinParam.token.name)),
            trailing:
                const CircleAssetsImgaeView(CoinGeckoUtils.logo, radius: 15),
            onTap: () {
              UriUtils.lunch(networkParam.marketUri!);
            },
          ),
      ],
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage(this.chainAccount);
  final ChainHandler chainAccount;

  @override
  Widget build(BuildContext context) {
    final hasProvider = chainAccount.provider() != null;

    return IgnorePointer(
      ignoring: !hasProvider,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: _AccountPageView(chainAccount),
      ),
    );
  }
}

class _AccountButtons extends StatelessWidget {
  const _AccountButtons(this.chainAccount);
  final ChainHandler chainAccount;

  @override
  Widget build(BuildContext context) {
    final hasProvider = chainAccount.provider() != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () {
            context.openSliverDialog(
                (ctx) => ShareAccountView(
                      address: chainAccount.account.address,
                      network: chainAccount.network,
                    ),
                "address_sharing".tr);
          },
          heroTag: null,
          child: const Icon(Icons.download),
        ),
        WidgetConstant.width8,
        if (hasProvider) ...[
          WidgetConstant.width8,
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              context.to(PageRouter.transactionPage(chainAccount.network),
                  argruments: chainAccount);
            },
            child: const Icon(Icons.upload),
          )
        ]
      ],
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
      case NetworkType.bitcoinAndForked:
        if (network is WalletBitcoinCashNetwork) {
          return BitcoinCashAccountPageView(chainAccount: chainAccount);
        }
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
      default:
        return const SizedBox();
    }
  }
}

class _AddressDetailsView extends StatelessWidget {
  const _AddressDetailsView({required this.account, required this.onPressed});
  final CryptoAddress account;
  final IntVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.mediaQuery.size.width,
        padding: WidgetConstant.padding10,
        decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: WidgetConstant.borderBottom8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CopyTextIcon(
                dataToCopy: account.address.toAddress,
                color: context.colors.onPrimary,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    account.accountName != null
                        ? RichText(
                            maxLines: 1,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: account.accountName,
                                  style: context.textTheme.labelLarge?.copyWith(
                                      color: context.colors.onPrimary)),
                              if (account.type != null)
                                TextSpan(
                                    text: " (${account.type!.tr})",
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                            color: context.colors.onPrimary))
                            ]))
                        : account.type == null
                            ? WidgetConstant.sizedBox
                            : Text(
                                account.accountName ?? account.type!.tr,
                                style: context.textTheme.labelLarge
                                    ?.copyWith(color: context.colors.onPrimary),
                              ),
                    if (account.multiSigAccount)
                      Text(
                        "multi_signature".tr,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.onPrimary),
                      ),
                    OneLineTextWidget(
                      account.address.toAddress,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            FocusScope(
              autofocus: false,
              canRequestFocus: false,
              child: SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.north_east_sharp),
                    onPressed: () {
                      onPressed(0);
                    },
                    child: Text("export_private_key".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.north_east_sharp),
                    onPressed: () {
                      onPressed(1);
                    },
                    child: Text("export_public_key".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.edit),
                    onPressed: () {
                      onPressed(3);
                    },
                    child: Text("account_name".tr),
                  ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.remove),
                    onPressed: () {
                      onPressed(2);
                    },
                    child: Text("remove_account".tr),
                  ),
                ],
                style: ButtonStyle(
                    iconColor:
                        WidgetStatePropertyAll(context.colors.onPrimary)),
                child: const SizedBox(
                  width: APPConst.double40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.more_vert_sharp),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class _NetworkPageTabbar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NetworkPageTabbar(
      {required this.child, required this.chainAccount, Key? key})
      : super(key: key);
  final ChainHandler chainAccount;
  final PreferredSizeWidget child;
  @override
  Size get preferredSize =>
      chainAccount.services.isEmpty ? Size.zero : child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return TabBar(
        tabs: chainAccount.services.map((e) => Tab(text: e.tr)).toList());
  }
}
