import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class MonitorRippleTokenView extends StatelessWidget {
  const MonitorRippleTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<RippleChain>(
      title: "add_token".tr,
      childBulder: (wallet, account, switchRippleAccount) {
        return _MonitorRippleTokenView(
            account: account, wallet: wallet, provider: account.provider()!);
      },
    );
  }
}

class _MonitorRippleTokenView extends StatefulWidget {
  const _MonitorRippleTokenView(
      {required this.account, required this.wallet, required this.provider});
  final RippleChain account;
  final WalletProvider wallet;
  final RippleClient provider;

  @override
  State<_MonitorRippleTokenView> createState() =>
      __MonitorRippleTokenViewState();
}

class __MonitorRippleTokenViewState extends State<_MonitorRippleTokenView>
    with SafeState {
  late final address = widget.account.address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "__MonitorRippleTokenViewState");
  final Set<RippleIssueToken> tokens = {};
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      return await widget.provider.provider
          .request(XRPRPCFetchTokens(account: address.address.toAddress));
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      final toRippleIssue = result.result
          .map((e) => RippleIssueToken.create(
              balance: e.balance,
              token: Token(name: e.symbol, symbol: e.symbol),
              issuer: e.issuer))
          .toList();
      tokens.addAll(toRippleIssue);
      progressKey.success();
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

  Future<void> add(RippleIssueToken token) async {
    final result = await widget.wallet.wallet.addNewToken(
        token: RippleIssueToken.create(
            balance: token.balance.value.balance.toDecimal(),
            token: token.token,
            issuer: token.issuer),
        address: address,
        account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(RippleIssueToken token) async {
    final result = await widget.wallet.wallet.removeToken(
      token: token,
      address: address,
      account: widget.account,
    );
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(RippleIssueToken token, bool exist) async {
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
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: (c) {
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
                          widget.account.address.tokens.contains(token);
                      return Column(
                        children: [
                          ContainerWithBorder(
                            onRemove: () {
                              context.openSliverDialog(
                                  (ctx) => DialogTextView(
                                      buttonWidget: AsyncDialogDoubleButtonView(
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
                                        buttonWidget:
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
                                    CircleTokenImageView(token.token,
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
                                        Text(token.issuer,
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
