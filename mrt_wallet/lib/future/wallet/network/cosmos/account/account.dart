import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class CosmosAccountPageView extends StatelessWidget {
  const CosmosAccountPageView({required this.chainAccount, super.key});
  final CosmosChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      const _CosmosAccountPageView(),
      _CosmosTokenView(account: chainAccount)
    ]);
  }
}

class _CosmosAccountPageView extends StatelessWidget {
  const _CosmosAccountPageView();

  @override
  Widget build(BuildContext context) {
    return const AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(children: []),
      )
    ]);
  }
}

class _CosmosTokenView extends StatelessWidget {
  const _CosmosTokenView({required this.account});
  final CosmosChain account;
  ICosmosAddress get address => account.address;

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
                          context.to(PageRouter.importCosmosTokens);
                        },
                        child: Text("import_token".tr))
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
                    context.to(PageRouter.importCosmosTokens);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.separated(
        separatorBuilder: (context, index) => WidgetConstant.divider,
        itemBuilder: (context, index) {
          final CW20Token token = address.tokens[index];
          return TokenDetailsView(
            onSelectWidget: WidgetConstant.sizedBox,
            onSelect: () {
              context.openDialogPage<TokenAction>("token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                      token: token,
                      address: address,
                      account: account,
                      transferArgruments: account,
                      transferPath: PageRouter.cosmosTransaction));
            },
            token: token,
          );
        },
        itemCount: address.tokens.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      )
    ]);
  }
}
