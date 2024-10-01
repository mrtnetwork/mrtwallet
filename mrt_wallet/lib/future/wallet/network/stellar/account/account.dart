import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/operations/operations.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class StellarAccountPageView extends StatelessWidget {
  const StellarAccountPageView({required this.chainAccount, super.key});
  final StellarChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      const _StellarServices(),
      _StellarTokenView(account: chainAccount),
    ]);
  }
}

class _StellarServices extends StatelessWidget {
  const _StellarServices();

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverList.separated(
          itemBuilder: (context, index) {
            final element = StellarConst.supportedOperations.elementAt(index);
            return AppListTile(
              title: Text(element.translate.tr),
              onTap: () {
                context.to(PageRouter.stellarTransaction);
              },
              subtitle: Text(element.description),
              maxLine: 3,
              trailing: const Icon(Icons.arrow_forward),
            );
          },
          separatorBuilder: (context, index) => WidgetConstant.divider,
          itemCount: StellarConst.supportedOperations.length),
    ]);
  }
}

class _StellarTokenView extends StatelessWidget {
  const _StellarTokenView({required this.account});
  final StellarChain account;
  IStellarAddress get address => account.address;

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
                      Text("no_tokens_found".tr),
                      WidgetConstant.height20,
                      FilledButton(
                          onPressed: () {
                            context.to(PageRouter.stellarImportToken);
                          },
                          child: Text("monitor_my_tokens".tr))
                    ],
                  ),
                ),
              ),
            )
          : SliverToBoxAdapter(
              child: AppListTile(
              leading: const Icon(Icons.token),
              onTap: () {
                context.to(PageRouter.stellarImportToken);
              },
              title: Text("manage_tokens".tr),
              subtitle: Text("add_or_remove_tokens".tr),
            )),
      SliverList.builder(
          itemBuilder: (context, index) {
            final StellarIssueToken token = address.tokens[index];
            return ContainerWithBorder(
              onRemove: () {
                context.openDialogPage<TokenAction>(
                  "token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                      token: token,
                      address: address,
                      account: account,
                      transferPath: PageRouter.stellarTransaction),
                );
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
                      Text(token.token.name,
                          style: context.textTheme.labelLarge),
                      Text(token.issuer,
                          style: context.colors.onPrimaryContainer
                              .bodySmall(context)),
                      CoinPriceView(
                          liveBalance: token.balance,
                          token: token.token,
                          style: context.colors.onPrimaryContainer
                              .titleLarge(context)),
                    ],
                  )),
                ],
              ),
            );
          },
          itemCount: address.tokens.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false)
    ]);
  }
}
