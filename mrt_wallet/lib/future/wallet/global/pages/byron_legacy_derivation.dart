import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/crypto/worker.dart' show Bip32AddressIndex;

class ByronLegacyKeyDerivationView extends StatefulWidget {
  const ByronLegacyKeyDerivationView(
      {super.key, required this.coin, required this.curve});
  final CryptoCoins coin;
  final EllipticCurveTypes curve;

  @override
  State<ByronLegacyKeyDerivationView> createState() =>
      _ByronLegacyKeyDerivationViewState();
}

class _ByronLegacyKeyDerivationViewState
    extends State<ByronLegacyKeyDerivationView> {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_AddressTypePathSetupState");
  final Map<Bip44Levels, GlobalKey<NumberTextFieldState>> levelStateKeys = {
    Bip44Levels.change: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_4"),
    Bip44Levels.addressIndex: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_5"),
  };

  late final bool isSupportNoneHardend;
  late final int minIndex;

  String? validate(String? v, Bip44Levels level) {
    if (levels[level] == null) {
      return "bip32_key_index_validate".tr;
    }
    return null;
  }

  final Map<Bip44Levels, Bip44LevelsDetails?> levels = {
    Bip44Levels.change: null,
    Bip44Levels.addressIndex: null,
  };
  void onChangedValue(int? v, Bip44Levels level) {
    if (v == null) return;
    try {
      final index = Bip44LevelsDetails.fromIntIndex(v, level);
      if (!index.isHardened && !isSupportNoneHardend) return;
      levels[level] = Bip44LevelsDetails.fromIntIndex(v, level);
    } on Exception {
      levels[level] = null;
    } finally {
      path = calculatePath();
      setState(() {});
    }
  }

  String? helperText(Bip44Levels level) {
    if (levels[level]?.isHardened ?? false) {
      return "hardened_index"
          .tr
          .replaceOne(levels[level]!.unHardendValue.toString());
    }
    return null;
  }

  Color? hardenedColor(Bip44Levels level) {
    return (levels[level]?.isHardened ?? false)
        ? context.theme.iconTheme.color
        : null;
  }

  bool isHardened(Bip44Levels level) {
    return (levels[level]?.isHardened ?? false);
  }

  void onSubmit() {
    if (!(form.currentState?.validate() ?? false)) return;
    final keyIndex = Bip32AddressIndex.byronLegacy(
      firstIndex: levels[Bip44Levels.change]!.index,
      secoundIndex: levels[Bip44Levels.addressIndex]!.index,
      currencyCoin: widget.coin,
    );
    context.pop(keyIndex);
  }

  void onTapHardened(Bip44Levels level) {
    if (levels[level]?.isHardened ?? true) return;
    stateKey(level)
        .currentState
        ?.changeIndex(Bip32KeyIndex.hardenIndex(levels[level]!.index).index);
  }

  GlobalKey<NumberTextFieldState> stateKey(Bip44Levels level) {
    return levelStateKeys[level]!;
  }

  String path = "";

  String calculatePath() {
    String p = "m";
    for (final i in levels.values) {
      if (i == null) {
        p += "/***";
      } else {
        p += "/${i.path}";
      }
    }
    return p;
  }

  @override
  void initState() {
    super.initState();
    isSupportNoneHardend = widget.curve != EllipticCurveTypes.ed25519;
    minIndex =
        isSupportNoneHardend ? 0 : Bip32KeyDataConst.hardenKeyIndexMinValue;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PageTitleSubtitle(
          //     title: "bip32_key_derivation".tr,
          //     body: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         LargeTextView([
          //           "bip32_derivation_desc".tr,
          //           "bip32_derivation_desc2".tr,
          //           "bip32_derivation_desc3".tr,
          //           if (!isSupportNoneHardend)
          //             "ed25519_support_derivation_desc".tr
          //         ])
          //       ],
          //     )),
          // PageTitleSubtitle(
          //     title: "choose_index_each_level".tr,
          //     body: Text("bip32_level_desc".tr)),
          Text("path".tr, style: context.textTheme.titleMedium),
          WidgetConstant.height8,
          ContainerWithBorder(
              child: Text(
            path,
            style: context.textTheme.bodyLarge,
          )),
          WidgetConstant.height20,
          NumberTextField(
            label: "first_index".tr,
            max: Bip32KeyDataConst.keyIndexMaxVal,
            helperText: helperText(Bip44Levels.change),
            key: stateKey(Bip44Levels.change),
            // suffixIcon: _HardenIconView(
            //   isHarden: (level) => isHardened(level),
            //   level: Bip44Levels.change,
            //   onTap: (level) => onTapHardened(level),
            // ),
            min: minIndex,
            onChange: (v) {
              onChangedValue(v, Bip44Levels.change);
            },
            validator: (v) => validate(v, Bip44Levels.change),
          ),
          NumberTextField(
            label: "second_index".tr,
            max: Bip32KeyDataConst.keyIndexMaxVal,
            helperText: helperText(Bip44Levels.addressIndex),
            key: stateKey(Bip44Levels.addressIndex),
            // suffixIcon: _HardenIconView(
            //   isHarden: (level) => isHardened(level),
            //   level: Bip44Levels.addressIndex,
            //   onTap: (level) => onTapHardened(level),
            // ),
            min: minIndex,
            onChange: (v) {
              onChangedValue(v, Bip44Levels.addressIndex);
            },
            validator: (v) => validate(v, Bip44Levels.addressIndex),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: onSubmit,
                child: Text("setup_derivation_path".tr),
              ),
            ],
          )
        ],
      ),
    );
  }
}
