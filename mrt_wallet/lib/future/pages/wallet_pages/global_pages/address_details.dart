import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/app/constant/custom_colors.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AddressDetailsView extends StatelessWidget {
  const AddressDetailsView(
      {required this.address,
      required this.isSelected,
      super.key,
      this.showBalance = true});
  final CryptoAddress address;
  final bool isSelected;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    switch (address.runtimeType) {
      case IBitcoinAddress:
        return _BitcoinAddressDetailsView(
            address: address as IBitcoinAddress,
            isSelected: isSelected,
            showBalance: showBalance);
      case IBitcoinMultiSigAddress:
        return _BitcoinAddressDetailsView(
            address: address as IBitcoinAddress,
            isSelected: isSelected,
            showBalance: showBalance);
      default:
        return const SizedBox();
    }
  }
}

class _BitcoinAddressDetailsView extends StatelessWidget {
  const _BitcoinAddressDetailsView(
      {required this.address,
      required this.isSelected,
      required this.showBalance});
  final IBitcoinAddress address;
  final bool isSelected;
  final bool showBalance;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(address.addressType.value,
                    style: context.textTheme.labelLarge)),
            if (isSelected)
              Text("selected".tr,
                  style: context.theme.textTheme.labelLarge
                      ?.copyWith(color: CustomColors.green)),
          ],
        ),
        OneLineTextWidget(address.address.toAddress),
        OneLineTextWidget(address.keyIndex.path.tr),
        if (showBalance)
          CoinPriceView(account: address, style: context.textTheme.titleLarge),
      ],
    );
  }
}
