import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SetupRippleAddressView extends StatefulWidget {
  final AddressDerivationController controller;
  const SetupRippleAddressView({super.key, required this.controller});
  @override
  State<SetupRippleAddressView> createState() => _SetupRippleAddressViewState();
}

class _SetupRippleAddressViewState extends State<SetupRippleAddressView>
    with SafeState {
  XrpAddressType addressTyoe = XrpAddressType.classic;
  bool get isXAddress => addressTyoe == XrpAddressType.xAddress;
  int tag = 0;
  void onChangeTag(int newTag) {
    if (newTag < 0 || newTag > mask32 - 1) return;
    tag = newTag;
  }

  String? validateTag(String? v) {
    if (!isXAddress) return null;
    final newTag = int.tryParse(v ?? "");
    if (newTag == null || newTag < 0 || newTag > mask32 - 1) {
      return "tag_validator".tr;
    }
    return null;
  }

  void onSelectAddressType() {
    addressTyoe = isXAddress ? XrpAddressType.classic : XrpAddressType.xAddress;
    setState(() {});
  }

  void generateAddress() async {
    final keyIndex = await widget.controller
        .getCoin(context: context, seedGeneration: SeedTypes.bip39);
    if (keyIndex == null) return;

    final newAccount = RippleNewAddressParams(
      deriveIndex: keyIndex,
      tag: isXAddress ? tag : null,
      coin: widget.controller.network.coins.firstWhere(
          (element) => element.conf.type == keyIndex.currencyCoin.conf.type),
    );
    widget.controller.generateAddress(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCheckListTile(
          title: Text("x_address".tr, style: context.textTheme.titleMedium),
          contentPadding: EdgeInsets.zero,
          subtitle: TextAndLinkView(
            text: "x_address_desc".tr,
            url: LinkConst.reviewRippleXAddress,
            linkDesc: "read_more".tr,
          ),
          value: isXAddress,
          onChanged: (v) {
            onSelectAddressType();
          },
        ),
        WidgetConstant.height20,
        APPAnimatedSwitcher(widgets: {
          XrpAddressType.classic: (c) => WidgetConstant.sizedBox,
          XrpAddressType.xAddress: (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("tag".tr, style: context.textTheme.titleMedium),
                  Text("enter_tag_desc".tr),
                  WidgetConstant.height8,
                  NumberTextField(
                      label: "tag".tr,
                      onChange: onChangeTag,
                      validator: validateTag,
                      defaultValue: tag,
                      max: mask32 - 1,
                      min: 0),
                ],
              )
        }, enable: addressTyoe),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: generateAddress,
              child: Text("generate_address".tr),
            ),
          ],
        )
      ],
    );
  }
}
