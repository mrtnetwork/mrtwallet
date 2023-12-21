import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/app/constant/custom_colors.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contract_core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class AddressDetailsView extends StatelessWidget {
  const AddressDetailsView({
    required this.address,
    required this.isSelected,
    super.key,
    this.showBalance = true,
  });

  final CryptoAccountAddress address;
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
                child: address.accountName != null
                    ? RichText(
                        maxLines: 1,
                        text: TextSpan(children: [
                          TextSpan(
                              text: address.accountName,
                              style: context.textTheme.labelLarge),
                          TextSpan(
                              text: " (${address.type.tr})",
                              style: context.textTheme.bodySmall)
                        ]))
                    : Text(address.type.tr,
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

class ContactAddressView extends StatelessWidget {
  const ContactAddressView({super.key, required this.contact});
  final ContactCore contact;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OneLineTextWidget(contact.name, style: context.textTheme.labelLarge),
        Text(contact.type.tr, style: context.textTheme.bodySmall),
        OneLineTextWidget(contact.address),
      ],
    );
  }
}
