import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/token_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';

class TronAccountPageView extends StatelessWidget {
  const TronAccountPageView({required this.chainAccount, super.key});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    final account = chainAccount.account.address as ITronAddress;
    return TabBarView(children: [
      _Services(account: account),
      _TronTokenView(account: account),
      _TronTokenView(account: account, isTrc10: true),
    ]);
  }
}

class _TronTokenView extends StatelessWidget {
  const _TronTokenView({required this.account, this.isTrc10 = false});
  final ITronAddress account;
  final bool isTrc10;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final tokens = isTrc10 ? account.trc10Tokens : account.tokens;

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
                    context.to(isTrc10
                        ? PagePathConst.importTrc10Token
                        : PagePathConst.importTRC20Token);
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
              context.to(isTrc10
                  ? PagePathConst.importTrc10Token
                  : PagePathConst.importTRC20Token);
            },
            title: Text("manage_tokens".tr),
            subtitle: Text("add_or_remove_tokens".tr),
          ),
          WidgetConstant.divider,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final TokenCore token = tokens[index];
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
                        context.to(PagePathConst.tronTransfer,
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
            itemCount: tokens.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            shrinkWrap: true,
          )
        ],
      ),
    );
  }
}

class _Services extends StatelessWidget {
  const _Services({required this.account});
  final ITronAddress account;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppListTile(
            title: Text("multi_sig_addr".tr),
            subtitle: Text("establishing_multi_sig_addr".tr),
            onTap: () {
              context.to(PagePathConst.tronMultiSigAddress);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: Text("update_account_permission".tr),
            subtitle: Text("update_account_permissions".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronAccountUpdatePermissionValidator(
                      permissions: account.accountInfo!.permissions
                          .map((e) => e.clone())
                          .toList()));
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: Text("update_account".tr),
            subtitle: Text("modify_account_name".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronUpdateAccountValidator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: Text("tron_stack_v2".tr),
            subtitle: Text("frozen_balance".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronFreezBalanceV2Validator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: Text("tron_unstack_v2".tr),
            subtitle: Text("unfreeze_balance".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronUnFreezBalanceV2Validator(
                      accountInfo: account.accountInfo));
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: Text("delegated_resource".tr),
            subtitle: Text("delegate_resource_desc".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronDelegatedResourceV2Validator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: Text("undelegated_resource".tr),
            subtitle: Text("undelegated_resource_desc".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronUnDelegatedResourceV2Validator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: Text("create_witness".tr),
            subtitle: Text("create_witness_desc".tr),
            onTap: () {
              final validator = LiveTransactionValidator(
                  validator: TronCreateWitnessValidator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
          AppListTile(
            title: Text("update_witness".tr),
            subtitle: Text("update_witness_desc".tr),
            onTap: () {
              if (account.accountInfo == null) return;
              final validator = LiveTransactionValidator(
                  validator: TronUpdateWitnessValidator());
              context.to(PagePathConst.tronTransaction, argruments: validator);
            },
          ),
        ],
      ),
    );
  }
}
