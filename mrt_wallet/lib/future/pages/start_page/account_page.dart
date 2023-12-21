import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/account_page.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/account_page.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

import '../wallet_pages/account_pages/account_pages.dart';

class NetworkAccountPageView extends StatelessWidget {
  const NetworkAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          if (!wallet.haveAddress) return [];
          final account = wallet.networkAccount.address;
          return [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: SizedBox(
                  height: 80,
                  child: _AddressDetailsView(
                    account: account,
                    onPressed: (p0) {
                      switch (p0) {
                        case 1:
                          context.openSliverBottomSheet(
                            "publick_key".tr,
                            child: AccountPublicKeyView(
                                address: wallet.networkAccount.address),
                          );

                          break;
                        case 0:
                          context.to(PagePathConst.exportPrivateKey,
                              argruments: wallet.networkAccount.address);
                          break;
                        case 2:
                          context.to(PagePathConst.removeAccount,
                              argruments: wallet.networkAccount.address);
                        case 3:
                          context
                              .openSliverBottomSheet<String>(
                                "account_name".tr,
                                child: StringWriterView(
                                  defaultValue:
                                      wallet.networkAccount.address.accountName,
                                  regExp: AppGlobalConst.accountNameRegExp,
                                  title: PageTitleSubtitle(
                                      title: "setup_or_update_account_name".tr,
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
                                  value, wallet.networkAccount.address));

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
                              CircleAssetsImgaeView(
                                wallet.network.coinParam.logo,
                                radius: 40,
                              ),
                              WidgetConstant.height8,
                              Text(wallet.network.coinParam.token.name,
                                  style: context.textTheme.labelLarge),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CoinPriceView(
                                  account: wallet.networkAccount.address,
                                  style: context.textTheme.titleLarge,
                                ),
                                WidgetConstant.height8,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () {
                                        context.openSliverDialog(
                                            (ctx) => ShareAccountView(
                                                  address: wallet
                                                      .networkAccount.address,
                                                ),
                                            "address_sharing".tr);
                                      },
                                      heroTag: null,
                                      child: const Icon(Icons.download),
                                    ),
                                    WidgetConstant.width8,
                                    FloatingActionButton(
                                      heroTag: null,
                                      onPressed: () {
                                        context.to(
                                            PagePathConst.transactionPage(
                                                wallet.network));
                                      },
                                      child: const Icon(Icons.upload),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ];
        },
        body: !wallet.haveAddress
            ? Padding(
                padding: WidgetConstant.padding20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitleSubtitle(
                      title: "setup_network_address"
                          .tr
                          .replaceOne(wallet.network.coinParam.token.name),
                      body: Text("setup_network_address_desc"
                          .tr
                          .replaceOne(wallet.network.coinParam.token.name)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FixedElevatedButton(
                            onPressed: () {
                              context.to(
                                  PagePathConst.setupAddressPage(
                                      wallet.network),
                                  argruments: wallet.networkAccount);
                            },
                            child: Text("setup_address".tr)),
                      ],
                    )
                  ],
                ))
            : _AccountPageView(wallet));
  }
}

class _AccountPageView extends StatelessWidget {
  const _AccountPageView(this.wallet);
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    switch (wallet.network.runtimeType) {
      case AppBitcoinNetwork:
        return BitcoinAccountPageView(wallet: wallet);
      case AppXRPNetwork:
        return RippleAccountPageView(
            account: wallet.networkAccount.address as IXRPAddress);
      default:
        return const SizedBox();
    }
  }
}

class _AddressDetailsView extends StatelessWidget {
  const _AddressDetailsView({required this.account, required this.onPressed});
  final CryptoAccountAddress account;
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
                              TextSpan(
                                  text: " (${account.type.tr})",
                                  style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colors.onPrimary))
                            ]))
                        : Text(
                            account.accountName ?? account.type.tr,
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
                        MaterialStatePropertyAll(context.colors.onPrimary)),
                child: const SizedBox(
                  width: AppGlobalConst.double40,
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
