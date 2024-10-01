import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class TronAccountPageView extends StatelessWidget {
  const TronAccountPageView({required this.chainAccount, super.key});
  final TronChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) => false,
      child: TabBarView(children: [
        _Services(chainAccount),
        _TronTokenView(account: chainAccount),
        _TronTokenView(account: chainAccount, isTrc10: true),
      ]),
    );
  }
}

class _TronTokenView extends StatelessWidget {
  const _TronTokenView({required this.account, this.isTrc10 = false});
  final TronChain account;
  final bool isTrc10;
  ITronAddress get address => account.address;
  @override
  Widget build(BuildContext context) {
    final List<TronToken> tokens =
        isTrc10 ? address.trc10Tokens : address.tokens;
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
                          context.to(isTrc10
                              ? PageRouter.importTrc10Token
                              : PageRouter.importTRC20Token);
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
                    context.to(isTrc10
                        ? PageRouter.importTrc10Token
                        : PageRouter.importTRC20Token);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.builder(
        itemBuilder: (context, index) {
          final TronToken token = tokens[index];
          return ContainerWithBorder(
            onRemove: () {
              context.openDialogPage<TokenAction>(
                "token_info".tr,
                child: (ctx) => TokenDetailsModalView(
                  token: token,
                  address: address,
                  account: account,
                  transferPath: PageRouter.tronTransfer,
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
        itemCount: tokens.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      )
    ]);
  }
}

class _Services extends StatelessWidget {
  const _Services(this.chainAccount);
  final TronChain chainAccount;
  ITronAddress get account => chainAccount.address;
  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppListTile(
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PageRouter.tronMultiSigAddress,
                    argruments: chainAccount);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("update_account_permission".tr),
              subtitle: Text("update_account_permissions".tr),
              onTap: () {
                if (account.accountInfo == null) {
                  context.showAlert("account_not_found".tr);
                  return;
                }
                final validator = LiveTransactionForm(
                    validator: TronAccountUpdatePermissionForm(
                        permissions: account.accountInfo!.permissions
                            .map((e) => e.clone())
                            .toList()
                            .cast<AccountPermission>()));
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("update_account".tr),
              subtitle: Text("modify_account_name".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronUpdateAccountForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("tron_stack_v2".tr),
              subtitle: Text("frozen_balance".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronFreezBalanceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("tron_unstack_v2".tr),
              subtitle: Text("unfreeze_balance".tr),
              onTap: () {
                final validator = LiveTransactionForm(
                    validator: TronUnFreezBalanceV2Form(
                        accountInfo: account.accountInfo));
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("delegated_resource".tr),
              subtitle: Text("delegate_resource_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm(
                    validator: TronDelegatedResourceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("undelegated_resource".tr),
              subtitle: Text("undelegated_resource_desc".tr),
              onTap: () {
                final validator = LiveTransactionForm(
                    validator: TronUnDelegatedResourceV2Form());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            WidgetConstant.divider,
            AppListTile(
              title: Text("create_witness".tr),
              subtitle: Text("create_witness_desc".tr),
              onTap: () {
                final validator =
                    LiveTransactionForm(validator: TronCreateWitnessForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
            AppListTile(
              title: Text("update_witness".tr),
              subtitle: Text("update_witness_desc".tr),
              onTap: () {
                if (account.accountInfo == null) {
                  context.showAlert("account_not_found".tr);
                  return;
                }
                final validator =
                    LiveTransactionForm(validator: TronUpdateWitnessForm());
                context.to(PageRouter.tronTransaction, argruments: validator);
              },
            ),
          ],
        ),
      )
    ]);
  }
}
