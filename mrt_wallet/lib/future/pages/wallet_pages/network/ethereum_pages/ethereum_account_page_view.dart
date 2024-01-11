import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class ETHAccountPageView extends StatelessWidget {
  const ETHAccountPageView({required this.chainAccount, super.key});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(text: "services".tr),
            Tab(
              text: "tokens".tr,
            ),
          ]),
          Expanded(
              child: TabBarView(children: [
            _EthereumServiceView(chainAccount: chainAccount),
            _EthereumTokenView(
                account: chainAccount.account.address as IEthAddress),
          ]))
        ],
      ),
    );
  }
}

class _EthereumTokenView extends StatelessWidget {
  const _EthereumTokenView({required this.account});
  final IEthAddress account;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final tokens = account.tokens;

    if (tokens.isEmpty) {
      return Column(
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
      );
    }
    return Column(
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
          itemBuilder: (context, index) {
            final ETHERC20Token token = account.tokens[index];
            return ContainerWithBorder(
              onRemove: () {
                context
                    .openSliverDialog<TokenAction>(
                        (ctx) => TokenDetailsModalView(
                              token: token,
                              address: account,
                            ),
                        content: (ctx) => [
                              IconButton(
                                  onPressed: () {
                                    ctx.pop(TokenAction.delete);
                                  },
                                  icon: Icon(Icons.delete,
                                      color: context.colors.error))
                            ],
                        "token_info".tr)
                    .then((value) {
                  switch (value) {
                    case TokenAction.delete:
                      context.openSliverDialog(
                          (ctx) => DialogTextView(
                              buttomWidget: AsyncDialogDoubleButtonView(
                                firstButtonPressed: () =>
                                    wallet.removeToken(token, account),
                              ),
                              text: "remove_token_from_account".tr),
                          "remove_token".tr);
                      break;
                    case TokenAction.transfer:
                      context.to(PagePathConst.ethereumTransaction,
                          argruments: token);
                      break;
                    default:
                  }
                });
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
    );
  }
}

class _EthereumServiceView extends StatelessWidget {
  const _EthereumServiceView({required this.chainAccount});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final apiProvider = chainAccount.provider().serviceProvider;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppListTile(
                  title: Text("api_provider_service".tr),
                  subtitle: Text(apiProvider.provider.serviceName),
                  onTap: () {
                    context.openSliverDialog(
                        (ctx) => SelectProviderView(
                              network: chainAccount.network,
                              selectedProvider: apiProvider.provider,
                              showEdit: true,
                            ), content: (context) {
                      return [
                        WidgetConstant.width8,
                        IconButton(
                            onPressed: () {
                              context.pop(true);
                            },
                            icon: const Icon(Icons.edit))
                      ];
                    }, "service_provider".tr).then(
                      (value) {
                        if (value == null) return;
                        if (value is ApiProviderService) {
                          wallet.changeProvider(value);
                        } else {
                          context.to(PagePathConst.editEvmNetwork,
                              argruments: chainAccount.network);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                  padding: WidgetConstant.paddingHorizontal20,
                  child: ProviderTrackerStatusView(provider: apiProvider))
            ],
          ),
        ],
      ),
    );
  }
}
