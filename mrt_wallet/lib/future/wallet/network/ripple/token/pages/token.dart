import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/account/state.dart';
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
        return _MonitorRippleTokenView(account: account, wallet: wallet);
      },
    );
  }
}

class _MonitorRippleTokenView extends StatefulWidget {
  const _MonitorRippleTokenView({required this.account, required this.wallet});
  final WalletProvider wallet;
  final RippleChain account;
  @override
  RippleAccountState createState() => __MonitorRippleTokenViewState();
}

class __MonitorRippleTokenViewState
    extends RippleAccountState<_MonitorRippleTokenView> {
  @override
  RippleChain get account => widget.account;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "__MonitorRippleTokenViewState");
  final Set<RippleIssueToken> tokens = {};
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      return await client.accountTokens(address);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      tokens.addAll(result.result);
      progressKey.success();
    }
  }

  @override
  void onInitOnce() {
    fetchingTokens();
  }

  Future<void> add(RippleIssueToken token) async {
    final result = await widget.wallet.wallet.addNewToken(
        token: RippleIssueToken.create(
            balance: token.balance.value.balance.toDecimal(),
            token: token.token,
            issuer: token.issuer),
        address: address,
        account: account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(RippleIssueToken token) async {
    final result = await widget.wallet.wallet.removeToken(
      token: token,
      address: address,
      account: account,
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
  void safeDispose() {
    for (final i in tokens) {
      i.balance.dispose();
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
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (context, index) {
                      final token = tokens.elementAt(index);
                      final bool exist =
                          widget.account.address.tokens.contains(token);
                      return ContainerWithBorder(
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
                                    buttonWidget: AsyncDialogDoubleButtonView(
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
                                CircleTokenImageView(token.token, radius: 40),
                                WidgetConstant.width8,
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(token.token.name,
                                        style: context
                                            .onPrimaryTextTheme.labelLarge),
                                    Text(token.issuer,
                                        style: context
                                            .onPrimaryTextTheme.bodySmall),
                                    CoinPriceView(
                                      liveBalance: token.balance,
                                      token: token.token,
                                      style:
                                          context.onPrimaryTextTheme.labelLarge,
                                      symbolColor:
                                          context.colors.onPrimaryContainer,
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ],
                        ),
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
