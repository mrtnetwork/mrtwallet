import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class RippleAccountPageView extends StatelessWidget {
  const RippleAccountPageView({required this.chainAccount, super.key});
  final RippleChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _RippleServicesView(chainAccount: chainAccount),
      _RippleTokensView(account: chainAccount),
    ]);
  }
}

class _RippleServicesView extends StatelessWidget {
  const _RippleServicesView({required this.chainAccount});
  final RippleChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!chainAccount.address.multiSigAccount) ...[
                AppListTile(
                  title: Text("multi_sig_addr".tr),
                  subtitle: Text("establishing_multi_sig_addr".tr),
                  onTap: () {
                    context.to(PageRouter.rippleMultisigAddress,
                        argruments: chainAccount);
                  },
                ),
                WidgetConstant.divider
              ],
              AppListTile(
                title: Text("trust_set".tr),
                subtitle: Text("tust_line_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleTrustSetForm>(
                      validator: RippleTrustSetForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: Text("account_set".tr),
                subtitle: Text("account_set_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleAccountSetForm>(
                      validator: RippleAccountSetForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                onTap: () {
                  context.to(PageRouter.rippleAddNfts);
                },
                title: Text("manage_nfts".tr),
                subtitle: Text("manage_nfts_desc".tr),
              ),
              AppListTile(
                title: const Text("NFTokenMint"),
                subtitle: Text("ripple_mint_nftoken_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleMintTokenForm>(
                      validator: RippleMintTokenForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenBurn"),
                subtitle: Text("ripple_nftoken_burn_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippeBurnTokenForm>(
                      validator: RippeBurnTokenForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenCreateOffer"),
                subtitle: Text("ripple_create_nftoken_offer_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleCreateOfferForm>(
                      validator: RippleCreateOfferForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("NFTokenCancelOffer"),
                subtitle: Text("ripple_nftoken_cancel_offer_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleCancelOfferForm>(
                      validator: RippleCancelOfferForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("EscrowCreate"),
                subtitle: Text("ripple_escrow_create_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowCreateForm>(
                      validator: RippleEscrowCreateForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("EscrowFinish"),
                subtitle: Text("ripple_escrow_finish_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowFinishForm>(
                      validator: RippleEscrowFinishForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              AppListTile(
                title: const Text("EscrowCancel"),
                subtitle: Text("ripple_escrow_cancel_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleEscrowCancelForm>(
                      validator: RippleEscrowCancelForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("SetRegularKey"),
                subtitle: Text("ripple_regular_key_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleRegularKeyForm>(
                      validator: RippleRegularKeyForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
              WidgetConstant.divider,
              AppListTile(
                title: const Text("SignerListSet"),
                subtitle: Text("ripple_set_signer_list_desc".tr),
                onTap: () {
                  final validator = LiveTransactionForm<RippleSignerListForm>(
                      validator: RippleSignerListForm());
                  context.to(PageRouter.rippleTransaction,
                      argruments: validator);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _RippleTokensView extends StatelessWidget {
  const _RippleTokensView({required this.account});
  final RippleChain account;
  IXRPAddress get address => account.address;

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
                            context.to(PageRouter.rippleAddToken);
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
                context.to(PageRouter.rippleAddToken);
              },
              title: Text("manage_tokens".tr),
              subtitle: Text("add_or_remove_tokens".tr),
            )),
      SliverList.builder(
          itemBuilder: (context, index) {
            final RippleIssueToken token = address.tokens[index];
            return ContainerWithBorder(
              onRemove: () {
                context.openDialogPage<TokenAction>(
                  "token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                    token: token,
                    address: address,
                    account: account,
                    transferPath: PageRouter.rippleTransfer,
                  ),
                );
              },
              onRemoveWidget: WidgetConstant.sizedBox,
              backgroundColor: Colors.transparent,
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
          itemCount: address.tokens.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false)
    ]);
  }
}
