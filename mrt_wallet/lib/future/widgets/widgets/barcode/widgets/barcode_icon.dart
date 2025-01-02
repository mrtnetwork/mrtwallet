import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class BarcodeScannerIconView extends StatelessWidget {
  const BarcodeScannerIconView(this.onBarcodeScanned,
      {this.isSensitive = false, super.key});
  final StringVoid onBarcodeScanned;
  final bool isSensitive;
  @override
  Widget build(BuildContext context) {
    final hasBarcodeScanner = context
        .watch<WalletProvider>(StateConst.main)
        .appSetting
        .supportBarcodeScanner;
    if (!hasBarcodeScanner) return WidgetConstant.sizedBox;
    return IconButton(
      onPressed: () {
        context
            .to<String>(PageRouter.barcodeScanner, argruments: isSensitive)
            .then((s) {
          if (s != null) {
            onBarcodeScanned(s);
          }
        });
      },
      icon: const Icon(Icons.qr_code),
    );
  }
}
