import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class Bip32KeyDerivationView extends StatefulWidget {
  const Bip32KeyDerivationView(
      {super.key, required this.coin, required this.curve});
  final CryptoCoins coin;
  final EllipticCurveTypes curve;

  @override
  State<Bip32KeyDerivationView> createState() => _Bip32KeyDerivationViewState();
}

class _Bip32KeyDerivationViewState extends State<Bip32KeyDerivationView> {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "_AddressTypePathSetupState");
  final Map<Bip44Levels, GlobalKey<NumberTextFieldState>> levelStateKeys = {
    Bip44Levels.purpose: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_1"),
    Bip44Levels.coin: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_2"),
    Bip44Levels.account: GlobalKey<NumberTextFieldState>(
        debugLabel: "_AddressTypePathSetupState_3"),
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
    Bip44Levels.purpose: null,
    Bip44Levels.coin: null,
    Bip44Levels.account: null,
    Bip44Levels.change: null,
    Bip44Levels.addressIndex: null,
  };
  void onChangedValue(String? v, Bip44Levels level) {
    if (v == null) return;
    try {
      final index = Bip44LevelsDetails.fromIntIndex(int.parse(v), level);
      if (!index.isHardened && !isSupportNoneHardend) return;
      levels[level] = Bip44LevelsDetails.fromIntIndex(int.parse(v), level);
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

  void onSubmit() {
    if (!(form.currentState?.validate() ?? false)) return;
    final keyIndex = Bip32AddressIndex.fromBip44KeyIndexDetais(
        levels.values.toList().cast());
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
          PageTitleSubtitle(
              title: "bip32_key_derivation".tr,
              subtitle: "p_note".tr,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("bip32_derivation_desc".tr),
                  WidgetConstant.height8,
                  Text("bip32_derivation_desc2".tr),
                  WidgetConstant.height8,
                  Text("bip32_derivation_desc3".tr),
                  if (!isSupportNoneHardend) ...[
                    WidgetConstant.height8,
                    Text("ed25519_support_derivation_desc".tr)
                  ]
                ],
              )),
          PageTitleSubtitle(
              title: "choose_index_each_level".tr,
              body: Text("bip32_level_desc".tr)),
          PageTitleSubtitle(
              title: "path".tr,
              body: AnimatedSwitcher(
                duration: AppGlobalConst.animationDuraion,
                child: Container(
                  key: ValueKey<String>(path),
                  padding: WidgetConstant.padding10,
                  decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: WidgetConstant.border8),
                  child: Text(
                    path,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              )),
          WidgetConstant.height20,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: NumberTextField(
                  label: "p_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  defaultValue:
                      (widget.coin.proposal as BipProposal).purpose.index,
                  helperText: helperText(Bip44Levels.purpose),
                  key: stateKey(Bip44Levels.purpose),
                  min: minIndex,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.purpose);
                  },
                  validator: (v) => validate(v, Bip44Levels.purpose),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.purpose);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.purpose),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "c_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.coin),
                  key: stateKey(Bip44Levels.coin),
                  defaultValue:
                      Bip32KeyIndex.hardenIndex(widget.coin.conf.coinIdx).index,
                  min: minIndex,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.coin);
                  },
                  validator: (v) => validate(v, Bip44Levels.coin),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.coin);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.coin),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "a_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.account),
                  key: stateKey(Bip44Levels.account),
                  min: minIndex,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.account);
                  },
                  validator: (v) => validate(v, Bip44Levels.account),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.account);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.account),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "change_level".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.change),
                  key: stateKey(Bip44Levels.change),
                  min: minIndex,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.change);
                  },
                  validator: (v) => validate(v, Bip44Levels.change),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.change);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.change),
                        )),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: NumberTextField(
                  label: "address_index".tr,
                  max: Bip32KeyDataConst.keyIndexMaxVal,
                  helperText: helperText(Bip44Levels.addressIndex),
                  key: stateKey(Bip44Levels.addressIndex),
                  min: minIndex,
                  onChange: (v) {
                    onChangedValue(v, Bip44Levels.addressIndex);
                  },
                  validator: (v) => validate(v, Bip44Levels.addressIndex),
                ),
              ),
              WidgetConstant.width8,
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    onTapHardened(Bip44Levels.addressIndex);
                  },
                  child: IgnorePointer(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.h_mobiledata,
                          color: hardenedColor(Bip44Levels.addressIndex),
                        )),
                  ))
            ],
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
