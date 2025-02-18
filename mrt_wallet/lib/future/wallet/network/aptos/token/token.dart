import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/account/state.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class AptosImportFATTokensView extends StatelessWidget {
  const AptosImportFATTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<AptosChain>(
      title: "import_token".tr,
      clientRequired: true,
      allowEmptyAccount: false,
      childBulder: (wallet, account, onAccountChanged) {
        return _AptosImportFATTokensView(account: account, wallet: wallet);
      },
    );
  }
}

class _AptosImportFATTokensView extends StatefulWidget {
  const _AptosImportFATTokensView(
      {required this.account, required this.wallet});
  final AptosChain account;
  final WalletProvider wallet;
  @override
  State<_AptosImportFATTokensView> createState() =>
      __AptosImportFATTokensViewState();
}

class __AptosImportFATTokensViewState
    extends AptosAccountState<_AptosImportFATTokensView> {
  @override
  AptosChain get account => widget.account;
  List<AptosFATokens> tokens = [];
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "_AptosImportFATTokensView");
  Future<void> fetchTokens() async {
    final result = await MethodUtils.call(() async {
      return await client.getAccountFTTokens(address.networkAddress);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      tokens = result.result;
      progressKey.success();
    }
  }

  Future<void> add(AptosFATokens token) async {
    final result = await widget.wallet.wallet
        .addNewToken(token: token, address: address, account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> removeToken(AptosFATokens token) async {
    final result = await widget.wallet.wallet
        .removeToken(token: token, address: address, account: widget.account);
    if (result.hasError) throw result.error!;
    return result.result;
  }

  Future<void> onTap(AptosFATokens token, bool exist) async {
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
  void onInitOnce() {
    super.onInitOnce();
    fetchTokens();
  }

  @override
  void safeDispose() {
    super.safeDispose();
    for (final i in tokens) {
      if (!address.tokens.contains(i)) {
        i.balance.dispose();
      }
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
                      physics: WidgetConstant.noScrollPhysics,
                      separatorBuilder: (context, index) =>
                          WidgetConstant.divider,
                      itemBuilder: (context, index) {
                        final token = tokens.elementAt(index);
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
                      itemCount: tokens.length),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
