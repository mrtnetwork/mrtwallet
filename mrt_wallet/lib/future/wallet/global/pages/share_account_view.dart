import 'package:flutter/material.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'address_details.dart';

class ShareAccountView extends StatelessWidget {
  const ShareAccountView(
      {required this.address, super.key, required this.network});
  final ChainAccount address;
  final WalletNetwork network;

  @override
  Widget build(BuildContext context) {
    return BarcodeView(
        title: CopyTextIcon(
            dataToCopy: address.address.toAddress,
            isSensitive: false,
            widget: Padding(
                padding: WidgetConstant.padding5,
                child:
                    AddressDetailsView(address: address, showBalance: false))),
        barcodeData: address.address.toAddress,
        shareSubject: network.coinParam.token.name,
        shareText: address.accountToString());
  }
}
