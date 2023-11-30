import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SelectAddress extends StatefulWidget {
  const SelectAddress({super.key, required this.network});
  final AppBitcoinNetwork network;

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> with SafeState {
  final GlobalKey<AppTextFieldState> textFieldKey =
      GlobalKey(debugLabel: "SelectAddress");
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "SelectAddress_1");
  String _address = "";
  void onChange(String v) {
    _address = v;
  }

  BitcoinAddress? validateBitcoinNetwork(String address) {
    try {
      return BitcoinAddress.fromAddress(
          address, widget.network.coinParam.transacationNetwork);
    } on ArgumentError {
      return null;
    }
  }

  String? validator(String? v) {
    if (v == null) {
      return "invalid_network_address".tr;
    }
    final addr = validateBitcoinNetwork(v);
    if (addr == null) {
      return "invalid_network_address".tr;
    }
    return null;
  }

  void onPaste(String v) {
    textFieldKey.currentState?.updateText(v);
  }

  void onSetup() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final addr = validateBitcoinNetwork(_address);
    if (context.mounted) {
      context.pop(addr!);
    }
  }

  void fromMyAccount(CryptoAddress? account) {
    if (account == null) return;
    onPaste(account.address.toAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          PageTitleSubtitle(
              title: "address_recipient_funds".tr,
              body: Text("receiver_address_desc".tr)),
          AppTextField(
            key: textFieldKey,
            label: "address".tr,
            maxLines: 3,
            suffixIcon: Column(
              children: [
                PasteTextIcon(onPaste: onPaste),
                MyAccountIcon(
                  onTap: () {
                    context
                        .openSliverBottomSheet<CryptoAddress>(
                          const SwitchOrSelectAccountView(),
                          "select_account".tr,
                          minExtent: 0.5,
                          maxExtend: 0.9,
                          initialExtend: 0.7,
                        )
                        .then(fromMyAccount);
                  },
                ),
              ],
            ),
            validator: validator,
            onChanged: onChange,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                  padding: WidgetConstant.paddingVertical20,
                  onPressed: onSetup,
                  child: Text("setup_address".tr))
            ],
          )
        ],
      ),
    );
  }
}
