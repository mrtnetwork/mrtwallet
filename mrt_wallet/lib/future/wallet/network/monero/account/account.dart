import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

import 'state.dart';

class MoneroAccountPageView extends StatelessWidget {
  const MoneroAccountPageView({required this.chainAccount, super.key});
  final MoneroChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _MoneroServices(chainAccount),
      _TransactionView(chain: chainAccount)
    ]);
  }
}

class _MoneroServices extends StatelessWidget {
  const _MoneroServices(this.account);
  final MoneroChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(children: [
          LiveWidget(
            () {
              final value = account.config.showInitializeAlert;
              return APPAnimatedSize(
                  isActive: value,
                  onActive: (context) => ErrorTextContainer(
                      enableTap: false,
                      oTapError: account.hideAlert,
                      errorIcon: Icons.close,
                      error: "monero_slow_chain_tracking_alert".tr),
                  onDeactive: (context) => WidgetConstant.sizedBox);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.sync),
            title: Text("sync_options".tr),
            subtitle: Text("monero_sync_options_desc".tr),
            onTap: () {
              context.to(PageRouter.moneroSyncOptions);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.sync),
            title: Text("sync_information".tr),
            subtitle: Text("view_account_block_sync".tr),
            onTap: () {
              context.to(PageRouter.moneroAccountSync);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.password),
            title: Text("monero_mnemonic".tr),
            subtitle: Text("generate_monero_private_key".tr),
            onTap: () {
              context.to(PageRouter.moneroMnemonic);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.handshake),
            title: Text("generate_transaction_proof".tr),
            subtitle: Text("monero_tx_proof_desc3".tr),
            onTap: () {
              context.to(PageRouter.moneroGenerateProof);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.verified),
            title: Text("verify_transaction_proof".tr),
            subtitle: Text("monero_verify_proof_desc".tr),
            onTap: () {
              context.to(PageRouter.moneroVerifyProof);
            },
          ),
        ]),
      )
    ]);
  }
}

class MoneroAppBarActionView extends StatelessWidget {
  const MoneroAppBarActionView(this.chain, {super.key});
  final MoneroChain chain;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return switch (chain.config.status) {
      MoneroChainStatus.outputReceived => AccountAppbarActionView(
          onHide: chain.hideStatus,
          onAction: () {
            context.openDialogPage(
              "",
              child: (context) {
                return PasswordCheckerView(
                  accsess: WalletAccsessType.unlock,
                  onWalletAccess: (password) async {
                    wallet.wallet.moneroUpdatePendingTxes(account: chain);
                    return null;
                  },
                );
              },
            );
          },
          text: "account_tx_detected_desc".tr),
      _ => WidgetConstant.sizedBox
    };
  }
}

class _TransactionView extends StatefulWidget {
  const _TransactionView({required this.chain});
  final MoneroChain chain;

  @override
  State<_TransactionView> createState() => _MoneroAccountTransactioViewState();
}

class _MoneroAccountTransactioViewState
    extends MoneroAccountState<_TransactionView> {
  @override
  MoneroChain get account => widget.chain;
  List<MoneroWalletTransaction>? txes;

  Future<void> getAccountTx() async {
    txes = await readTxes();
    updateState();
  }

  @override
  void onInitOnce() {
    getAccountTx();
    super.onInitOnce();
  }

  @override
  void safeDispose() {
    super.safeDispose();
    txes = null;
  }

  @override
  void didUpdateWidget(covariant _TransactionView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      Shimmer(
          onActive: (context) => EmptyItemSliverWidgetView(
                isEmpty: txes?.isEmpty ?? false,
                itemBuilder: () {
                  return SliverList.separated(
                      itemBuilder: (context, index) {
                        return TransactionView(
                            transaction: txes![index], chain: widget.chain);
                      },
                      separatorBuilder: (context, index) =>
                          WidgetConstant.divider,
                      itemCount: txes?.length);
                },
              ),
          enable: txes != null,
          sliver: true)
    ]);
  }
}
