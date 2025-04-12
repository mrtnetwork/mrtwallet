import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/account/state.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

class CosmosImportTokenView extends StatelessWidget {
  const CosmosImportTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<CosmosChain>(
      title: "import_token".tr,
      clientRequired: true,
      childBulder: (wallet, account, onAccountChanged) {
        return _CosmosImportTokenView(
            apiProvider: account.client, account: account, wallet: wallet);
      },
    );
  }
}

class _CosmosImportTokenView extends StatefulWidget {
  const _CosmosImportTokenView(
      {required this.apiProvider, required this.account, required this.wallet});
  final CosmosClient apiProvider;
  final CosmosChain account;
  final WalletProvider wallet;
  @override
  State<_CosmosImportTokenView> createState() => __CosmosImportTokenViewState();
}

class __CosmosImportTokenViewState
    extends CosmosAccountState<_CosmosImportTokenView> with ProgressMixin {
  @override
  CosmosChain get account => widget.account;

  List<CosmosChainAsset> allTokens = [];

  void fetchTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;

    final result = await MethodUtils.call(() async {
      return await client.getAddressTokens(address);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      // tokens.addAll(result.result);
      allTokens = [
        ...address.tokens.map((e) => CosmosChainAsset.cw20Token(e)),
        ...result.result
      ];
      if (allTokens.isNotEmpty) {
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

  Future<void> add(CW20Token token) async {
    await widget.wallet.wallet
        .addNewToken(token: token, address: address, account: widget.account);
  }

  Future<void> removeToken(CW20Token token) async {
    await widget.wallet.wallet.removeToken(
      token: token,
      address: address,
      account: widget.account,
    );
  }

  Future<void> onTap(CW20Token token, bool exist) async {
    try {
      if (exist) {
        await removeToken(token);
      } else {
        await add(token);
      }
    } finally {
      updateState();
    }
  }

  void updateToken(CosmosChainAsset token, Token updatedToken) {
    final index = allTokens.indexOf(token);
    if (index.isNegative) return;
    final newToken = CosmosChainAsset.cw20Token(CW20Token.create(
        balance: token.balance.balance,
        token: updatedToken,
        denom: token.coin.denom));
    allTokens[index] = newToken;
    updateState();
    onTap(newToken.cw20token!, false);
  }

  @override
  void safeDispose() {
    super.safeDispose();
    for (final i in allTokens) {
      if (!address.tokens.contains(i.cw20token)) {
        i.cw20token?.balance.dispose();
      }
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
      backToIdle: APPConst.oneSecoundDuration,
      initialWidget:
          ProgressWithTextView(text: "fetching_account_token_please_wait".tr),
      child: (c) {
        return CustomScrollView(
          slivers: [
            EmptyItemSliverWidgetView(
              isEmpty: allTokens.isEmpty,
              itemBuilder: () => SliverToBoxAdapter(
                child: ConstraintsBoxView(
                  padding: WidgetConstant.padding20,
                  child: ListView.separated(
                    physics: WidgetConstant.noScrollPhysics,
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (context, index) {
                      final token = allTokens.elementAt(index);
                      final bool exist =
                          addressTokens.contains(token.cw20token);
                      final cw20Token = token.cw20token;
                      if (cw20Token != null) {
                        return TokenDetailsView(
                            onSelect: () {
                              context.openSliverDialog(
                                  (ctx) => DialogTextView(
                                      buttonWidget: AsyncDialogDoubleButtonView(
                                        firstButtonPressed: () =>
                                            onTap(cw20Token, exist),
                                      ),
                                      text: exist
                                          ? "remove_token_from_account".tr
                                          : "add_token_to_your_account".tr),
                                  exist ? "remove_token".tr : "add_token".tr);
                            },
                            onSelectIcon: APPCheckBox(
                                value: exist,
                                ignoring: true,
                                onChanged: (value) {}),
                            token: token.cw20token!);
                      }
                      return ContainerWithBorder(
                        onRemoveIcon: APPCheckBox(
                            value: exist,
                            ignoring: true,
                            onChanged: (value) {}),
                        onRemove: () {
                          context.openSliverBottomSheet<bool>("update_token".tr,
                              bodyBuilder: (scrollController) =>
                                  UpdateTokenDetailsView(
                                      token: token.token,
                                      account: account,
                                      title: PageTitleSubtitle(
                                          title: "update_token_information".tr,
                                          body: AlertTextContainer(
                                              message:
                                                  "update_unknown_token_metadata_desc"
                                                      .tr,
                                              enableTap: false)),
                                      address: address,
                                      onUpdateToken: (context, updatedToken) {
                                        context.pop();
                                        updateToken(token, updatedToken);
                                      },
                                      scrollController: scrollController),
                              centerContent: false);
                        },
                        validate: false,
                        validateText: "update_unknown_token_metadata_desc".tr,
                        child: TokenDetailsWidget(
                            token: token.token,
                            tokenAddress: token.coin.denom,
                            color: context.colors.onPrimaryContainer,
                            radius: APPConst.double40,
                            balance: token.balance),
                      );
                    },
                    shrinkWrap: true,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemCount: allTokens.length,
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
