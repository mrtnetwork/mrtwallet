import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/share_account_view.dart';
import 'package:mrt_wallet/future/wallet/start/pages/menu_bar.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class AccountPageSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final WalletProvider wallet;
  AccountPageSliverHeaderDelegate(this.wallet);
  Chain get chainAccount => wallet.wallet.chain;
  bool get bottom => wallet.wallet.isOpen && chainAccount.haveAddress;
  PreferredSizeWidget get bottomWidget =>
      TabBar(tabs: chainAccount.services.map((e) => Tab(text: e.tr)).toList());
  final double accountSize = 150;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final enabled = shrinkOffset + minExtent > accountSize;
    return AppBar(
      bottom: bottomWidget,
      surfaceTintColor: context.colors.transparent,
      backgroundColor: context.colors.surface,
      foregroundColor: context.colors.onSurface,
      flexibleSpace: Stack(
        children: [
          APPAnimatedSwitcher(enable: enabled, widgets: {
            true: (c) => APPAnimatedContainer(
                alignment: Alignment.topCenter,
                isActive: bottom,
                onActive: (c) => AccountMenuButtonView(wallet: wallet),
                onDeactive: (p0) => WidgetConstant.sizedBox),
            false: (c) => Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    physics: WidgetConstant.noScrollPhysics,
                    child: Padding(
                      padding: WidgetConstant.padding20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleTokenImageView(
                                  chainAccount.network.coinParam.token,
                                  radius: 40),
                              WidgetConstant.height8,
                              Text(chainAccount.network.coinParam.token.name,
                                  style: context.textTheme.labelLarge),
                            ],
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CoinPriceView(
                                          account: chainAccount.address,
                                          style: context.textTheme.titleLarge,
                                          token: chainAccount
                                              .network.coinParam.token),
                                      WidgetConstant.height15,
                                      _AccountButtons(chainAccount)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AccountAppbarPopupMenu(wallet)
                        ],
                      ),
                    ),
                  ),
                )
          }),
          if (chainAccount.network.coinParam.isTestNet)
            Positioned(
                top: 0,
                right: 10,
                child: ToolTipView(
                  message: "testnet_price_desc".tr,
                  child: Card(
                    color: context.colors.errorContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: WidgetConstant.border4),
                    child: Padding(
                      padding: WidgetConstant.padding2,
                      child: Text(
                        "testnet".tr,
                        style: context.textTheme.labelSmall
                            ?.copyWith(color: context.colors.onErrorContainer),
                      ),
                    ),
                  ),
                ))
        ],
      ),
    );
  }

  @override
  double get maxExtent => (accountSize + bottomWidget.preferredSize.height);

  @override
  double get minExtent => (90 + bottomWidget.preferredSize.height);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _AccountButtons extends StatelessWidget {
  const _AccountButtons(this.chainAccount);
  final Chain chainAccount;

  @override
  Widget build(BuildContext context) {
    final hasProvider = !(chainAccount.provider()?.isConnect ?? false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () {
            context.openSliverDialog(
                (ctx) => ShareAccountView(
                      address: chainAccount.address,
                      network: chainAccount.network,
                    ),
                "address_sharing".tr);
          },
          heroTag: null,
          child: const Icon(Icons.download),
        ),
        WidgetConstant.width8,
        IgnorePointer(
          ignoring: hasProvider,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              context.to(PageRouter.transactionPage(chainAccount.network),
                  argruments: chainAccount);
            },
            child: const Icon(Icons.upload),
          ),
        )
      ],
    );
  }
}
