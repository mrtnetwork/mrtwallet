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

  List<CW20Token> tokens = [];
  List<CW20Token> allTokens = [];

  void fetchTokens() async {
    if (progressKey.isSuccess || progressKey.inProgress) return;

    final result = await MethodUtils.call(() async {
      return await client.getAddressTokens(address);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      tokens.addAll(result.result);
      allTokens = [...address.tokens, ...tokens];
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

  Future<void> add(CW20Token token) async {
    final result = await widget.wallet.wallet
        .addNewToken(token: token, address: address, account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(CW20Token token) async {
    final result = await widget.wallet.wallet.removeToken(
      token: token,
      address: address,
      account: widget.account,
    );
    if (result.hasError) throw result.error!;
    return result.result;
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

  @override
  void safeDispose() {
    super.safeDispose();
    for (final i in tokens) {
      i.balance.dispose();
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
                      final bool exist = addressTokens.contains(token);
                      return TokenDetailsView(
                          onSelect: () {
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
                          onSelectIcon: APPCheckBox(
                              value: exist,
                              ignoring: true,
                              onChanged: (value) {}),
                          token: token);
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
