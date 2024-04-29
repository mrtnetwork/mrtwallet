import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class ETHAccountPageView extends StatelessWidget {
  const ETHAccountPageView({required this.chainAccount, super.key});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _EthereumTokenView(account: chainAccount.account.address as IEthAddress),
    ]);
  }
}

class _EthereumTokenView extends StatelessWidget {
  const _EthereumTokenView({required this.account});
  final IEthAddress account;

  @override
  Widget build(BuildContext context) {
    final tokens = account.tokens;

    if (tokens.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.token, size: AppGlobalConst.double80),
              WidgetConstant.height8,
              Text("no_tokens_found".tr),
              WidgetConstant.height20,
              FilledButton(
                  onPressed: () {
                    context.to(PagePathConst.importERC20Token);
                  },
                  child: Text("import_token".tr))
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          AppListTile(
            leading: const Icon(Icons.token),
            onTap: () {
              context.to(PagePathConst.importERC20Token);
            },
            title: Text("manage_tokens".tr),
            subtitle: Text("add_or_remove_tokens".tr),
          ),
          WidgetConstant.divider,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final ETHERC20Token token = account.tokens[index];
              return ContainerWithBorder(
                onRemove: () {
                  context.openDialogPage<TokenAction>(
                    "token_info".tr,
                    child: (ctx) => TokenDetailsModalView(
                      token: token,
                      address: account,
                      transferPath: PagePathConst.ethereumTransaction,
                    ),
                  );
                },
                onRemoveWidget: WidgetConstant.sizedBox,
                child: Row(
                  children: [
                    CircleTokenImgaeView(token.token, radius: 40),
                    WidgetConstant.width8,
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(token.token.name,
                            style: context.textTheme.labelLarge),
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
            itemCount: account.tokens.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            shrinkWrap: true,
          )
        ],
      ),
    );
  }
}
