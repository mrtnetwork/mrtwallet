import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:stellar_dart/stellar_dart.dart';

class MonitorStellarTokenView extends StatelessWidget {
  const MonitorStellarTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<StellarChain>(
      title: "add_token".tr,
      childBulder: (wallet, account, switchRippleAccount) {
        return _MonitorStellarTokenView(chain: account, wallet: wallet);
      },
    );
  }
}

class _MonitorStellarTokenView extends StatefulWidget {
  const _MonitorStellarTokenView({required this.chain, required this.wallet});
  final StellarChain chain;
  final WalletProvider wallet;
  // final RippleClient provider;

  @override
  State<_MonitorStellarTokenView> createState() =>
      __MonitorStellarTokenViewState();
}

class __MonitorStellarTokenViewState extends State<_MonitorStellarTokenView>
    with SafeState {
  late final address = widget.chain.address;
  late final StellarClient client = widget.chain.provider()!;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "__MonitorStellarTokenViewState");
  final Set<StellarIssueToken> tokens = {};
  void fetchingTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodUtils.call(() async {
      final account = await client.getAccount(address.networkAddress);
      if (account == null) return <StellarAssetBalanceResponse>[];
      return account.balances.whereType<StellarAssetBalanceResponse>().toList();
    });

    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      final toRippleIssue = result.result.map((e) => e.toIssueToken()).toList();
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

  Future<void> add(StellarIssueToken token) async {
    final result = await widget.wallet.wallet.addNewToken(
        token: StellarIssueToken.create(
            balance: token.balance.value.balance,
            token: token.token,
            issuer: token.issuer,
            assetType: token.assetType),
        address: address,
        account: widget.chain);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(StellarIssueToken token) async {
    final result = await widget.wallet.wallet.removeToken(
      token: token,
      address: address,
      account: widget.chain,
    );
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(StellarIssueToken token, bool exist) async {
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
                      final bool exist = address.tokens.contains(token);
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
