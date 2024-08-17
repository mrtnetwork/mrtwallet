import 'package:flutter/material.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class SubstrateAccountPageView extends StatelessWidget {
  const SubstrateAccountPageView({required this.chainAccount, super.key});
  final SubstrateChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: [
      _SubstrateServices(),
    ]);
  }
}

class _SubstrateServices extends StatelessWidget {
  const _SubstrateServices();

  @override
  Widget build(BuildContext context) {
    return const AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [],
        ),
      )
    ]);
  }
}
