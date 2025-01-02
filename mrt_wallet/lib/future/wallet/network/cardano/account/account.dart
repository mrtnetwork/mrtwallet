import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/ada/src/address/era/shelly/ada_reward_address.dart';

List<PopupMenuItem<int>> cardanoAccountMenuButton(
    {required ADAChain chain,
    required BuildContext context,
    required int value}) {
  if (!chain.haveAddress) return [];
  final address = chain.address;
  if (!address.isRewardAddress && address.rewardAddress != null) {
    return [
      PopupMenuItem<int>(
        value: value,
        onTap: () {
          context.openSliverDialog(
            (context) => _ShowRewardAddress(chainAccount: chain.address),
            "reward_address".tr,
          );
        },
        child: AppListTile(
          trailing: const Icon(Icons.north_east_sharp),
          title:
              Text("reward_address".tr, style: context.textTheme.labelMedium),
        ),
      ),
    ];
  }
  return [];
}

class CardanoAccountPageView extends StatelessWidget {
  const CardanoAccountPageView({required this.chainAccount, super.key});
  final ADAChain chainAccount;
  @override
  Widget build(BuildContext context) {
    return TabBarView(physics: WidgetConstant.noScrollPhysics, children: [
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
          children: [],
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
    return BarcodeView(
        title: ContainerWithBorder(
          child: CopyableTextWidget(
            text: rewardAddress.address,
            color: context.colors.onPrimaryContainer,
            maxLines: 3,
          ),
        ),
        barcodeData: rewardAddress.address,
        shareSubject: "reward_address".tr,
        shareText: rewardAddress.address);
  }
}
