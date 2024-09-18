import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/address_derivation/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/worker.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

enum _V5ContectType {
  custom,
  client;

  bool get isCustomWalletId => this == client;
}

class SetupTonAddressView extends StatefulWidget {
  final AddressDerivationController controller;
  const SetupTonAddressView({super.key, required this.controller});
  @override
  State<SetupTonAddressView> createState() => _SetupTonAddressViewState();
}

class _SetupTonAddressViewState extends State<SetupTonAddressView>
    with SafeState {
  final GlobalKey<NumberTextFieldState> subwalletKey = GlobalKey();
  WalletVersion version = WalletVersion.v5R1;
  _V5ContectType v5Type = _V5ContectType.client;
  bool get hasSubWalletId => version.version > 2;
  WalletTonNetwork get network => widget.controller.network.toNetwork();
  bool bouncable = false;
  int defaultSubWalletId() {
    if (isVersion5) return 0;
    return TonConst.defaultSubWalletId + network.coinParam.workchain;
  }

  int? subWalletId;
  bool get isVersion5 => version == WalletVersion.v5R1;

  String subwalletIdLable = "sub_wallet_id";

  late int maximumSubWalletId = getMaximumSubWalletId();

  void onChangeVersion(WalletVersion? onChange) {
    if (onChange == null) return;
    version = onChange;
    maximumSubWalletId = getMaximumSubWalletId();
    updateSubWalletIdLable();
    updateState();
    subwalletKey.currentState?.setValue(defaultSubWalletId());
  }

  void updateSubWalletIdLable() {
    if (!isVersion5) {
      v5Type = _V5ContectType.client;
    } else {
      if (v5Type.isCustomWalletId) {
        subwalletIdLable = "wallet_id";
      } else {
        subwalletIdLable = "sub_wallet_id";
      }
    }
  }

  void onChangeV5Type(bool? _) {
    if (v5Type == _V5ContectType.client) {
      v5Type = _V5ContectType.custom;
    } else {
      v5Type = _V5ContectType.client;
    }
    maximumSubWalletId = getMaximumSubWalletId();
    updateSubWalletIdLable();
    updateState();
    subwalletKey.currentState?.setValue(defaultSubWalletId());
  }

  void onChangeBounce(bool? v) {
    bouncable = !bouncable;
    setState(() {});
  }

  int getMaximumSubWalletId() {
    if (isVersion5) {
      switch (v5Type) {
        case _V5ContectType.client:
          return TonConst.maximumV5SubWalletId;
        default:
          return TonConst.maximumWalletId;
      }
    }
    return TonConst.maximumSubWalletId;
  }

  void onChangeSubWalletId(int id) {
    if (id < 0 || id > maximumSubWalletId) {
      subWalletId = null;
    } else {
      subWalletId = id;
    }

    // TonConst.deciaml
  }

  String? validateSubWalletId(String? v) {
    if (!hasSubWalletId) return null;
    if (subWalletId == null) {
      return "sub_wallet_id_validator"
          .tr
          .replaceOne(maximumSubWalletId.toString());
    }
    return null;
  }

  void generateAddress() async {
    final keyIndex = await widget.controller
        .getCoin(context: context, seedGeneration: SeedTypes.bip39);
    if (keyIndex == null) return;
    if (widget.controller.form.currentState?.validate() ?? false) {
      if (hasSubWalletId && subWalletId == null) return;
      TonAccountContext? context;
      switch (version) {
        case WalletVersion.v1R1:
        case WalletVersion.v1R2:
        case WalletVersion.v1R3:
        case WalletVersion.v2R1:
        case WalletVersion.v2R2:
          context =
              TonAccountLegacyContext(version: version, bouncable: bouncable);
          break;
        case WalletVersion.v3R1:
        case WalletVersion.v3R2:
        case WalletVersion.v4:
          context = TonAccountSubWalletContext(
              version: version,
              bouncable: bouncable,
              subwalletId: subWalletId!);
          break;
        case WalletVersion.v5R1:
          context = switch (v5Type) {
            _V5ContectType.client => TonAccountV5SubWalletContext(
                version: version,
                bouncable: bouncable,
                subwalletId: subWalletId!),
            _V5ContectType.custom => TonAccountV5CustomContext(
                version: version,
                bouncable: bouncable,
                contextId: subWalletId!),
          };
          break;
        default:
      }
      if (context == null) return;
      final newAccount = TonNewAddressParams(
          deriveIndex: keyIndex,
          context: context,
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
          url: LinkConst.reviewTonWalletContract,
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
            duration: APPConst.animationDuraion,
            child: hasSubWalletId
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("sub_wallet_id".tr,
                          style: context.textTheme.titleMedium),
                      TextAndLinkView(
                        text: "sub_wallet_id_desc".tr,
                        url: LinkConst.reviewTonSubWalletId,
                        linkDesc: "read_more".tr,
                      ),
                      if (isVersion5) ...[
                        WidgetConstant.height20,
                        AppCheckListTile(
                          contentPadding: EdgeInsets.zero,
                          onChanged: onChangeV5Type,
                          value: v5Type == _V5ContectType.custom,
                          title: Text("use_wallet_id".tr,
                              style: context.textTheme.titleMedium),
                          subtitle: TextAndLinkView(
                            text: "ton_v5_wallet_desc".tr,
                            url: LinkConst.reviewTonV5,
                            linkDesc: "read_more".tr,
                          ),
                        )
                      ],
                      WidgetConstant.height8,
                      NumberTextField(
                          key: subwalletKey,
                          label: subwalletIdLable.tr,
                          onChange: onChangeSubWalletId,
                          validator: validateSubWalletId,
                          defaultValue: subWalletId,
                          max: maximumSubWalletId,
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
                url: LinkConst.tonBounceableAddressReview,
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
