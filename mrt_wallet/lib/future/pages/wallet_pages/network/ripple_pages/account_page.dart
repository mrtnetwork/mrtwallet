import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/ripple/ripple.dart';

class RippleAccountPageView extends StatelessWidget {
  const RippleAccountPageView({required this.chainAccount, super.key});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _RippleServicesView(chainAccount: chainAccount),
      _RippleTokensView(account: chainAccount.account.address as IXRPAddress),
    ]);
  }
}

class _RippleServicesView extends StatelessWidget {
  const _RippleServicesView({required this.chainAccount});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!chainAccount.account.address.multiSigAccount) ...[
            AppListTile(
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PagePathConst.rippleMultisigAddress);
              },
            ),
            WidgetConstant.divider
          ],
          AppListTile(
            title: Text("trust_set".tr),
            subtitle: Text("tust_line_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleTrustSetValidator>(
                      validator: RippleTrustSetValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: Text("account_set".tr),
            subtitle: Text("account_set_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleAccountSetValidator>(
                      validator: RippleAccountSetValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            onTap: () {
              context.to(PagePathConst.rippleAddNfts);
            },
            title: Text("manage_nfts".tr),
            subtitle: Text("manage_nfts_desc".tr),
          ),
          AppListTile(
            title: const Text("NFTokenMint"),
            subtitle: Text("ripple_mint_nftoken_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleMintTokenValidator>(
                      validator: RippleMintTokenValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("NFTokenBurn"),
            subtitle: Text("ripple_nftoken_burn_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippeBurnTokenValidator>(
                      validator: RippeBurnTokenValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("NFTokenCreateOffer"),
            subtitle: Text("ripple_create_nftoken_offer_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleCreateOfferValidator>(
                      validator: RippleCreateOfferValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("NFTokenCancelOffer"),
            subtitle: Text("ripple_nftoken_cancel_offer_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleCancelOfferValidator>(
                      validator: RippleCancelOfferValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: const Text("EscrowCreate"),
            subtitle: Text("ripple_escrow_create_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleEscrowCreateValidator>(
                      validator: RippleEscrowCreateValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("EscrowFinish"),
            subtitle: Text("ripple_escrow_finish_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleEscrowFinishValidator>(
                      validator: RippleEscrowFinishValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          AppListTile(
            title: const Text("EscrowCancel"),
            subtitle: Text("ripple_escrow_cancel_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleEscrowCancelValidator>(
                      validator: RippleEscrowCancelValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: const Text("SetRegularKey"),
            subtitle: Text("ripple_regular_key_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleRegularKeyValidator>(
                      validator: RippleRegularKeyValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
          WidgetConstant.divider,
          AppListTile(
            title: const Text("SignerListSet"),
            subtitle: Text("ripple_set_signer_list_desc".tr),
            onTap: () {
              final validator =
                  LiveTransactionValidator<RippleSignerListValidator>(
                      validator: RippleSignerListValidator());
              context.to(PagePathConst.rippleTransaction,
                  argruments: validator);
            },
          ),
        ],
      ),
    );
  }
}

class _RippleTokensView extends StatelessWidget {
  const _RippleTokensView({required this.account});
  final IXRPAddress account;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
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
                    context.to(PagePathConst.rippleAddToken);
                  },
                  child: Text("monitor_my_tokens".tr))
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
              context.to(PagePathConst.rippleAddToken);
            },
            title: Text("manage_tokens".tr),
            subtitle: Text("add_or_remove_tokens".tr),
          ),
          WidgetConstant.divider,
          ListView.builder(
            physics: WidgetConstant.noScrollPhysics,
            itemBuilder: (context, index) {
              final RippleIssueToken token = account.tokens[index];
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
                        context.to(PagePathConst.rippleTransfer,
                            argruments: token);
                        break;
                      default:
                    }
                  });
                },
                onRemoveWidget: WidgetConstant.sizedBox,
                backgroundColor: Colors.transparent,
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
                        Text(token.issuer, style: context.textTheme.bodySmall),
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
