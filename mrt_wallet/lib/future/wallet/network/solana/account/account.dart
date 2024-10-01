import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class SolanaAccountPageView extends StatelessWidget {
  const SolanaAccountPageView({required this.chainAccount, super.key});
  final SolanaChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      const _SolanaServices(),
      _SolanaTokenView(account: chainAccount),
    ]);
  }
}

class _SolanaTokenView extends StatelessWidget {
  const _SolanaTokenView({required this.account});
  final SolanaChain account;
  ISolanaAddress get address => account.address;

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
                          context.to(PageRouter.importSPLTokens);
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
                    context.to(PageRouter.importSPLTokens);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.builder(
        itemBuilder: (context, index) {
          final SolanaSPLToken token = address.tokens[index];
          return ContainerWithBorder(
            onRemove: () {
              context.openDialogPage<TokenAction>("token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                        token: token,
                        address: address,
                        account: account,
                        transferPath: PageRouter.solanaTransfer,
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

class _SolanaServices extends StatelessWidget {
  const _SolanaServices();

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              title: Text("associated_token_program".tr),
              subtitle: Text("create_associated_token_account".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm<SolanaCreateAssociatedTokenAccountForm>(
                        validator: SolanaCreateAssociatedTokenAccountForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("create_account".tr),
              subtitle: Text("solana_create_account_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm<SolanaCreateAccountForm>(
                    validator: SolanaCreateAccountForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("initialize_mint".tr),
              subtitle: Text("initiailize_mint_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm<SolanaInitializeMintForm>(
                    validator: SolanaInitializeMintForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("mint_to".tr),
              subtitle: Text("mint_to_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm<SolanaMintToForm>(
                    validator: SolanaMintToForm());
                context.to(PageRouter.solanaTransaction, argruments: validator);
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
