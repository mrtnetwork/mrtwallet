import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class BitcoinCashAccountPageView extends StatelessWidget {
  const BitcoinCashAccountPageView({super.key, required this.chainAccount});
  final BitcoinChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _Services(chainAccount),
    ]);
  }
}

class _Services extends StatelessWidget {
  const _Services(this.chainAccount);
  final BitcoinChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              AppListTile(
                title: Text("multi_signature".tr),
                subtitle: Text("establishing_multi_sig_addr".tr),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  context.to(PageRouter.setupBitcoinMultsig,
                      argruments: chainAccount);
                },
              ),
              AppListTile(
                title: Text("pro_transaction_builder".tr),
                subtitle: Text("bch_pro_builder_desc".tr),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () {
                  context.to(PageRouter.bitcoinCashTransaction,
                      argruments: chainAccount);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
