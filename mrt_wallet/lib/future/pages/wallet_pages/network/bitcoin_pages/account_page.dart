import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/chain/chain.dart';

class BitcoinAccountPageView extends StatelessWidget {
  const BitcoinAccountPageView({super.key, required this.chainAccount});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: [
      _Services(),
    ]);
  }
}

class _Services extends StatelessWidget {
  const _Services();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppListTile(
            title: Text("multi_signature".tr),
            subtitle: Text("establishing_multi_sig_addr".tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              context.to(PagePathConst.setupBitcoinMultsig);
            },
          ),
        ],
      ),
    );
  }
}
