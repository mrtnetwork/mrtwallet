import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class ShareAccountView extends StatelessWidget {
  const ShareAccountView({required this.address, super.key});
  final CryptoAddress address;

  @override
  Widget build(BuildContext context) {
    return BarcodeView(
        title: CopyTextIcon(
            dataToCopy: address.address.toAddress,
            widget: AddressDetailsView(
              address: address,
              isSelected: false,
              showBalance: false,
            )),
        barcodeData: address.address.toAddress,
        shareSubject: address.network.coinParam.coinName,
        shareText: address.accountToString());
  }
}
