import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details.dart';
import 'package:mrt_wallet/future/wallet/global/pages/token_details_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class AptosAccountPageView extends StatelessWidget {
  const AptosAccountPageView({required this.chainAccount, super.key});
  final AptosChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
      _AptosServices(account: chainAccount),
      _AptosTokenView(account: chainAccount),
    ]);
  }
}

class _AptosTokenView extends StatelessWidget {
  const _AptosTokenView({required this.account});
  final AptosChain account;
  IAptosAddress get address => account.address;

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
                          context.to(PageRouter.importAptosToken);
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
                    context.to(PageRouter.importAptosToken);
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
          final AptosFATokens token = address.tokens[index];
          return TokenDetailsView(
            onSelectWidget: WidgetConstant.sizedBox,
            onSelect: () {
              context.openDialogPage<TokenAction>("token_info".tr,
                  child: (ctx) => TokenDetailsModalView(
                      token: token,
                      address: address,
                      account: account,
                      transferPath: PageRouter.aptosTransfer));
            },
            token: token,
          );
        },
        itemCount: address.tokens.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      )
    ]);
  }
}

class _AptosServices extends StatelessWidget {
  const _AptosServices({required this.account});
  final AptosChain account;
  IAptosAddress get address => account.address;

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
                context.to(PageRouter.aptosMultisigAddress);
              },
            ),
            WidgetConstant.divider
          ],
        ),
      ),
    ]);
  }
}
