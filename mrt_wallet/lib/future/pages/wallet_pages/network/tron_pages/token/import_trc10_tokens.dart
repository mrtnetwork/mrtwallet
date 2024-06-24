import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/global/controller_tron_transaction_account.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';

class MonitorTronTRC10TokenView extends StatelessWidget {
  const MonitorTronTRC10TokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return ControllerTronTransactionAccountView(
      title: "add_token".tr,
      childBulder: (wallet, account, address, switchRippleAccount) {
        return _MonitorTronTRC10TokenView(
            address: address, wallet: wallet, provider: account.provider()!);
      },
    );
  }
}

class _MonitorTronTRC10TokenView extends StatefulWidget {
  const _MonitorTronTRC10TokenView(
      {required this.address, required this.wallet, required this.provider});
  final ITronAddress address;
  final WalletProvider wallet;
  final TVMApiProvider provider;

  @override
  State<_MonitorTronTRC10TokenView> createState() =>
      __MonitorTronTRC10TokenViewState();
}

class __MonitorTronTRC10TokenViewState extends State<_MonitorTronTRC10TokenView>
    with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "__MonitorTronTRC10TokenViewState");
  final Set<TronTRC10Token> tokens = {};
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodCaller.call(() async {
      if (widget.address.accountInfo == null) {
        await widget.provider.updateBalance(widget.address);
      }
      if (widget.address.accountInfo == null) {
        return null;
      }
      final tronAccount = widget.address.accountInfo!;
      if (tronAccount.assetV2.isEmpty) {
        return <TronTRC10Token>[];
      }
      final issueList = await widget.provider.getIssueAssetList();
      List<TronTRC10Token> accountTokens = [];
      for (final i in tronAccount.assetV2) {
        final token = issueList.firstWhere((element) => element.id == i.key);
        accountTokens.add(TronTRC10Token.create(
            balance: i.value,
            token: Token(
                name: token.name,
                symbol: token.abbr ?? token.name,
                decimal: token.precision ?? 0),
            tokenID: i.key));
      }
      return accountTokens;
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      if (result.result == null) {
        progressKey.errorText("account_not_found".tr, backToIdle: false);
      } else {
        tokens.addAll(result.result!);
        progressKey.success();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchingTokens();
  }

  @override
  void dispose() {
    for (final i in tokens) {
      i.balance.dispose();
    }
    super.dispose();
  }

  Future<void> add(TronTRC10Token token) async {
    final result = await widget.wallet.addNewToken(
        TronTRC10Token.create(
            balance: token.balance.value.balance,
            token: token.token,
            tokenID: token.tokenID),
        widget.address);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(TronTRC10Token token) async {
    final result = await widget.wallet.removeToken(token, widget.address);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(TronTRC10Token token, bool exist) async {
    try {
      if (exist) {
        await removeToken(token);
      } else {
        await add(token);
      }
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      initialStatus: PageProgressStatus.progress,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: () {
        return CustomScrollView(
          slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: tokens.isEmpty,
              itemBuilder: () => SliverToBoxAdapter(
                child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final token = tokens.elementAt(index);
                      final bool exist =
                          widget.address.trc10Tokens.contains(token);
                      return Column(
                        children: [
                          ContainerWithBorder(
                            onRemove: () {
                              context.openSliverDialog(
                                  (ctx) => DialogTextView(
                                      buttomWidget: AsyncDialogDoubleButtonView(
                                        firstButtonPressed: () =>
                                            onTap(token, exist),
                                      ),
                                      text: exist
                                          ? "remove_token_from_account".tr
                                          : "add_token_to_your_account".tr),
                                  exist ? "remove_token".tr : "add_token".tr);
                            },
                            onRemoveIcon: Checkbox(
                              value: exist,
                              onChanged: (value) {
                                context.openSliverDialog(
                                    (ctx) => DialogTextView(
                                        buttomWidget:
                                            AsyncDialogDoubleButtonView(
                                          firstButtonPressed: () =>
                                              onTap(token, exist),
                                        ),
                                        text: exist
                                            ? "remove_token_from_account".tr
                                            : "add_token_to_your_account".tr),
                                    exist ? "remove_token".tr : "add_token".tr);
                              },
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleTokenImgaeView(token.token,
                                        radius: 40),
                                    WidgetConstant.width8,
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(token.token.name,
                                            style:
                                                context.textTheme.labelLarge),
                                        Text(token.issuer!,
                                            style: context.textTheme.bodySmall),
                                        CoinPriceView(
                                            liveBalance: token.balance,
                                            token: token.token,
                                            style:
                                                context.textTheme.titleLarge),
                                      ],
                                    ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemCount: tokens.length,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}