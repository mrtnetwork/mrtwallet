import 'package:flutter/cupertino.dart';
import 'package:mrt_wallet/app/extention/context.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BitcoinAddressDetailsView extends StatelessWidget {
  const BitcoinAddressDetailsView({required this.account, super.key});
  final IBitcoinAddress account;
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(account.addressType.value, style: context.textTheme.labelLarge),
        Text(account.keyIndex.path),
        Text(account.address.toAddress),
      ],
    ));
  }
}
