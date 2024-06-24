import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/account_pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/solana/solana_address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/solana/spl_token.dart';
import 'package:mrt_wallet/provider/api/networks/solana/api_provider.dart';
import 'package:on_chain/solana/src/instructions/spl_token/constant.dart';

class SolanaImportSPLTokensView extends StatelessWidget {
  const SolanaImportSPLTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<APPSolanaNetwork, ISolanaAddress>(
      title: "import_spl_tokens".tr,
      childBulder: (wallet, account, address, network, onAccountChanged) {
        return _SolanaImportSPLTokensView(
          apiProvider: account.provider()!,
          account: address,
          wallet: wallet,
        );
      },
    );
  }
}

class _SolanaImportSPLTokensView extends StatefulWidget {
  const _SolanaImportSPLTokensView(
      {required this.apiProvider, required this.account, required this.wallet});
  final SolanaApiProvider apiProvider;
  final ISolanaAddress account;
  final WalletProvider wallet;
  @override
  State<_SolanaImportSPLTokensView> createState() =>
      __SolanaImportSPLTokensViewState();
}

class __SolanaImportSPLTokensViewState
    extends State<_SolanaImportSPLTokensView> {
  final List<SolanaSPLToken> tokens = [];
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_SolanaImportSPLTokensView");
  void fetchTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;
    final result = await MethodCaller.call(() async {
      final spltoken = await widget.apiProvider
          .getAccountTokens(widget.account.networkAddress);
      final splTokens2022 = await widget.apiProvider.getAccountTokens(
          widget.account.networkAddress,
          tokenProgram: SPLTokenProgramConst.token2022ProgramId);
      return [...spltoken, ...splTokens2022];
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      tokens.addAll(result.result.map((e) => e.toSplToken).toList());
      if (tokens.isNotEmpty) {
        progressKey.success();
      } else {
        progressKey.success(
            backToIdle: false,
            progressWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetConstant.checkCircleLarge,
                WidgetConstant.height8,
                Text("unable_to_locate_token".tr),
              ],
            ));
      }
    }
  }

  Future<void> add(SolanaSPLToken token) async {
    final result = await widget.wallet.addNewToken(token, widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(SolanaSPLToken token) async {
    final result = await widget.wallet.removeToken(token, widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(SolanaSPLToken token, bool exist) async {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTokens();
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
                    physics: WidgetConstant.noScrollPhysics,
                    itemBuilder: (context, index) {
                      final token = tokens.elementAt(index);
                      final bool exist = widget.account.tokens.contains(token);
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
                                        Text(
                                          token.mint.address,
                                          style: context.textTheme.bodySmall,
                                          maxLines: 1,
                                        ),
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
