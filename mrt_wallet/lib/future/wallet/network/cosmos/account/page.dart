import 'package:flutter/material.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class CosmosAccountPageView extends StatelessWidget {
  const CosmosAccountPageView({required this.chainAccount, super.key});
  final CosmosChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: [
      _CosmosAccountPageView(),
    ]);
  }
}

class _CosmosAccountPageView extends StatelessWidget {
  const _CosmosAccountPageView();

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
