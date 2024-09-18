import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';

class CardanoAccountPageView extends StatelessWidget {
  const CardanoAccountPageView({required this.chainAccount, super.key});
  final ADAChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _CardanoAccountPage(chainAccount: chainAccount.address),
    ]);
  }
}

class _CardanoAccountPage extends StatelessWidget {
  const _CardanoAccountPage({required this.chainAccount});
  final ICardanoAddress chainAccount;

  @override
  Widget build(BuildContext context) {
    return AccountTabbarScrollWidget(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [_ShowRewardAddress(chainAccount: chainAccount)],
        ),
      )
    ]);
  }
}

class _ShowRewardAddress extends StatelessWidget {
  const _ShowRewardAddress({required this.chainAccount});
  final ICardanoAddress chainAccount;
  @override
  Widget build(BuildContext context) {
    final ADARewardAddress? rewardAddress = chainAccount.rewardAddress;
    if (rewardAddress == null) return WidgetConstant.sizedBox;

    return ContainerWithBorder(
      onRemove: () {},
      onTapWhenOnRemove: false,
      onRemoveWidget:
          CopyTextIcon(dataToCopy: rewardAddress.address, isSensitive: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rewardAddress.addressType.name,
              style: context.textTheme.labelLarge),
          Text(
            rewardAddress.address,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
