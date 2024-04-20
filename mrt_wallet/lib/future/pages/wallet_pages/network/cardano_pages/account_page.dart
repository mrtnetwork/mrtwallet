import 'package:flutter/material.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class CardanoAccountPageView extends StatelessWidget {
  const CardanoAccountPageView({required this.chainAccount, super.key});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: []);
  }
}
