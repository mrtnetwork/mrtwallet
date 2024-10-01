import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TonAccountPageView extends StatelessWidget {
  const TonAccountPageView({required this.chainAccount, super.key});
  final TheOpenNetworkChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      const _TonServices(),
      _TonJettonsView(account: chainAccount),
    ]);
  }
}

class _TonJettonsView extends StatelessWidget {
  const _TonJettonsView({required this.account});
  final TheOpenNetworkChain account;
  ITonAddress get address => account.address;

  @override
  Widget build(BuildContext context) {
    final tokens = address.tokens;
    return AccountTabbarScrollWidget(slivers: [
      tokens.isEmpty
          ? SliverFillRemaining(
              child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.token, size: APPConst.double80),
                    WidgetConstant.height8,
                    Text("no_jettons_found".tr),
                    WidgetConstant.height20,
                    FilledButton(
                        onPressed: () {
                          context.to(PageRouter.importJettons);
                        },
                        child: Text("import_jettons".tr))
                  ],
                ),
              ),
            ))
          : SliverToBoxAdapter(
              child: Column(
              children: [
                AppListTile(
                  leading: const Icon(Icons.token),
                  onTap: () {
                    context.to(PageRouter.importJettons);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.builder(
        itemBuilder: (context, index) {
          final TonJettonToken token = address.tokens[index];
          return ContainerWithBorder(
            onRemove: () {
              context.openDialogPage<TonJettonToken>("token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                        token: token,
                        address: address,
                        transferPath: PageRouter.tonTransfer,
                        transferArgruments: account,
                        account: account,
                      ));
            },
            onRemoveWidget: WidgetConstant.sizedBox,
            child: Row(
              children: [
                CircleTokenImageView(token.token, radius: 40),
                WidgetConstant.width8,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(token.token.name, style: context.textTheme.labelLarge),
                    Text(token.issuer!, style: context.textTheme.bodySmall),
                    CoinPriceView(
                        liveBalance: token.balance,
                        token: token.token,
                        style: context.textTheme.titleLarge),
                  ],
                )),
              ],
            ),
          );
        },
        itemCount: address.tokens.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      )
    ]);
  }
}

class _TonServices extends StatelessWidget {
  const _TonServices();

  @override
  Widget build(BuildContext context) {
    return const AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [],
        ),
      )
    ]);
  }
}
