import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SetupRippleAddressView extends StatefulWidget {
  final AddressDerivationController controller;
  const SetupRippleAddressView({super.key, required this.controller});
  @override
  State<SetupRippleAddressView> createState() => _SetupRippleAddressViewState();
}

class _SetupRippleAddressViewState extends State<SetupRippleAddressView>
    with SafeState {
  Set<XrpAddressType> addressTyoe = {XrpAddressType.classic};
  bool get isXAddress => addressTyoe.first == XrpAddressType.xAddress;
  int tag = 0;
  void onChangeTag(String v) {
    final newTag = int.tryParse(v);
    if (newTag == null || newTag < 0 || newTag > mask32 - 1) return;
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

  void onSelectAddressType(Set<XrpAddressType> selectType) {
    addressTyoe = selectType;
    setState(() {});
  }

  void generateAddress() async {
    final keyIndex = await widget.controller.getCoin(context);
    if (keyIndex == null) return;
    final newAccount = RippleNewAddressParam(
        deriveIndex: keyIndex,
        type: keyIndex.currencyCoin.conf.type,
        tag: addressTyoe.first == XrpAddressType.classic ? null : tag);
    widget.controller.generateAddress(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AppSegmentedButton<XrpAddressType>(
                items: {
                  XrpAddressType.classic: XrpAddressType.classic.value.tr,
                  XrpAddressType.xAddress: XrpAddressType.xAddress.value.tr
                },
                selected: addressTyoe,
                onChangeSelected: onSelectAddressType,
              ),
            ),
          ],
        ),
        WidgetConstant.height20,
        AnimatedSize(
            duration: AppGlobalConst.animationDuraion,
            child: isXAddress
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "x_address_desc2".tr,
                          body: LargeTextView(["x_address_desc3".tr])),
                      Text("assigning_tag".tr,
                          style: context.textTheme.titleMedium),
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
                : const SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: generateAddress,
              child: Text("generate_address".tr),
            ),
          ],
        )
      ],
    );
  }
}
