import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:ton_dart/ton_dart.dart';

class SetupTonAddressView extends StatefulWidget {
  final AddressDerivationController controller;
  const SetupTonAddressView({super.key, required this.controller});
  @override
  State<SetupTonAddressView> createState() => _SetupTonAddressViewState();
}

class _SetupTonAddressViewState extends State<SetupTonAddressView>
    with SafeState {
  WalletVersion version = WalletVersion.v4;
  bool get hasSubWalletId => version.version > 2;
  APPTonNetwork get network => widget.controller.network.toNetwork();
  bool bouncable = false;
  int get defaultSubWalletId =>
      TonConst.defaultSubWalletId + network.coinParam.workchain;
  int? subWalletId;

  void onChangeVersion(WalletVersion? onChange) {
    final bool hasId = hasSubWalletId;
    version = onChange ?? version;
    if (hasId != hasSubWalletId) {
      subWalletId = defaultSubWalletId;
    }
    setState(() {});
  }

  void onChangeBounce(bool? v) {
    bouncable = !bouncable;
    setState(() {});
  }

  void onChangeSubWalletId(String v) {
    final id = int.tryParse(v);
    if (id == null || id < 0 || id > mask32 - 1) {
      subWalletId = null;
    } else {
      subWalletId = id;
    }
  }

  String? validateSubWalletId(String? v) {
    if (!hasSubWalletId) return null;
    if (subWalletId == null) {
      return "sub_wallet_id_validator".tr;
    }
    return null;
  }

  void generateAddress() async {
    final keyIndex = await widget.controller.getCoin(context);
    if (keyIndex == null) return;
    if (widget.controller.form.currentState?.validate() ?? false) {
      if (hasSubWalletId && subWalletId == null) return;
      final newAccount = TonNewAddressParam(
          deriveIndex: keyIndex,
          version: version,
          subWalletId: subWalletId,
          bouncable: bouncable,
          coin: widget.controller.coin);
      widget.controller.generateAddress(newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("types_of_wallet_contracts".tr,
            style: context.textTheme.titleMedium),
        TextAndLinkView(
          text: "ton_wallet_contract_desc".tr,
          url: AppLinkConst.reviewTonWalletContract,
          linkDesc: "read_more".tr,
        ),
        WidgetConstant.height8,
        AppDropDownBottom(
          items: {for (final i in WalletVersion.values) i: Text(i.name)},
          label: "wallet_type".tr,
          onChanged: onChangeVersion,
          value: version,
        ),
        WidgetConstant.height20,
        AnimatedSize(
            duration: AppGlobalConst.animationDuraion,
            child: hasSubWalletId
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("sub_wallet_id".tr,
                          style: context.textTheme.titleMedium),
                      TextAndLinkView(
                        text: "sub_wallet_id_desc".tr,
                        url: AppLinkConst.reviewTonSubWalletId,
                        linkDesc: "read_more".tr,
                      ),
                      WidgetConstant.height8,
                      NumberTextField(
                          label: "sub_wallet_id".tr,
                          onChange: onChangeSubWalletId,
                          validator: validateSubWalletId,
                          defaultValue: subWalletId ?? defaultSubWalletId,
                          max: mask32 - 1,
                          min: 0),
                    ],
                  )
                : const SizedBox()),
        WidgetConstant.height20,
        AppCheckListTile(
          contentPadding: EdgeInsets.zero,
          value: bouncable,
          onChanged: onChangeBounce,
          title: Text("bouncable".tr, style: context.textTheme.titleMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ton_address_type_desc".tr),
              TextAndLinkView(
                text: "ton_bounceable_vs_non_bounceable".tr,
                url: AppLinkConst.tonBounceableAddressReview,
                linkDesc: "read_more".tr,
              )
            ],
          ),
        ),
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
