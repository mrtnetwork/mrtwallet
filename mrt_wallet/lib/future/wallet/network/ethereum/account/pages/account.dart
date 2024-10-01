import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class ETHAccountPageView extends StatelessWidget {
  const ETHAccountPageView({required this.chainAccount, super.key});
  final EthereumChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _EthereumTokenView(account: chainAccount),
    ]);
  }
}

class _EthereumTokenView extends StatelessWidget {
  const _EthereumTokenView({required this.account});
  final EthereumChain account;
  IEthAddress get address => account.address;

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
                          context.to(PageRouter.importERC20Token);
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
                    context.to(PageRouter.importERC20Token);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.builder(
        itemBuilder: (context, index) {
          final ETHERC20Token token = address.tokens[index];
          return ContainerWithBorder(
            onRemove: () {
              context.openDialogPage<TokenAction>(
                "token_info".tr,
                child: (ctx) => TokenDetailsModalView(
                  token: token,
                  address: address,
                  account: account,
                  transferPath: PageRouter.ethereumTransaction,
                ),
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
