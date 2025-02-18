import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class SuiAccountPageView extends StatelessWidget {
  const SuiAccountPageView({required this.chainAccount, super.key});
  final SuiChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _SuiServices(account: chainAccount),
      _SuiTokenView(account: chainAccount),
    ]);
  }
}

class _SuiServices extends StatelessWidget {
  const _SuiServices({required this.account});
  final SuiChain account;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [
            AppListTile(
              title: Text("multi_sig_addr".tr),
              subtitle: Text("establishing_multi_sig_addr".tr),
              onTap: () {
                context.to(PageRouter.suiMultisigAddress);
              },
            ),
            WidgetConstant.divider
          ],
        ),
      ),
    ]);
  }
}

class _SuiTokenView extends StatelessWidget {
  const _SuiTokenView({required this.account});
  final SuiChain account;
  ISuiAddress get address => account.address;

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
                          context.to(PageRouter.importSuiToken);
                        },
                        child: Text("import_token".tr))
                  ],
                ),
              ),
            ))
          : SliverToBoxAdapter(
              child: Column(
              children: [
                AppListTile(
                  leading: const Icon(Icons.token),
                  onTap: () {
                    context.to(PageRouter.importSuiToken);
                  },
                  title: Text("manage_tokens".tr),
                  subtitle: Text("add_or_remove_tokens".tr),
                ),
                WidgetConstant.divider
              ],
            )),
      SliverList.separated(
          separatorBuilder: (context, index) => WidgetConstant.divider,
          itemBuilder: (context, index) {
            final SuiToken token = address.tokens[index];
            return TokenDetailsView(
              onSelectWidget: WidgetConstant.sizedBox,
              onSelect: () {
                context.openDialogPage<TokenAction>("token_info".tr,
                    child: (ctx) => TokenDetailsModalView(
                        token: token,
                        address: address,
                        account: account,
                        transferPath: PageRouter.suiTransfer));
              },
              token: token,
            );
          },
          itemCount: address.tokens.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false)
    ]);
  }
}
