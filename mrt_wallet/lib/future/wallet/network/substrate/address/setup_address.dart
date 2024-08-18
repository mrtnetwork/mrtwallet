import 'package:blockchain_utils/bip/bip/conf/bip/bip_coins.dart';
import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:blockchain_utils/bip/substrate/conf/substrate_coins.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/substrate.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SetupSubstrateAddressView extends StatefulWidget {
  final AddressDerivationController controller;
  const SetupSubstrateAddressView({super.key, required this.controller});
  @override
  State<SetupSubstrateAddressView> createState() =>
      _SetupSubstrateAddressViewState();
}

class _SetupSubstrateAddressViewState extends State<SetupSubstrateAddressView>
    with SafeState {
  SubstrateKeyAlgorithm? algorithm;

  late final Map<SubstrateKeyAlgorithm, Widget> algorithmTypesWidget = {
    for (final i in SubstrateKeyAlgorithm.values) i: Text(i.name.camelCase)
  };

  void onChangeCustomDerivation(bool? _) {
    if (algorithm == null) {
      algorithm = SubstrateKeyAlgorithm.sr25519;
    } else {
      algorithm = null;
    }
    updateState();
  }

  void onChangeAlgorithm(SubstrateKeyAlgorithm? alg) {
    algorithm = alg ?? algorithm;
    updateState();
  }

  void generateAddress() async {
    CryptoCoins coin;

    /// bip coin -Slip-10
    if (algorithm == null) {
      coin = widget.controller.network.coins.whereType<BipCoins>().first;
    } else {
      /// substrate coins
      coin = widget.controller.network.coins
          .whereType<SubstrateCoins>()
          .firstWhere((element) => element.conf.type == algorithm!.curve);
    }

    final keyIndex = await widget.controller.getCoin(
        context: context,
        seedGeneration:
            coin is BipCoins ? SeedTypes.bip39 : SeedTypes.bip39Entropy,
        selectedCoins: [coin]);
    if (keyIndex == null || keyIndex.currencyCoin.conf.type != coin.conf.type) {
      return;
    }
    final newAccount = SubstrateNewAddressParams(deriveIndex: keyIndex);
    widget.controller.generateAddress(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCheckListTile(
          title: Text("customize_key_derivation".tr,
              style: context.textTheme.titleMedium),
          contentPadding: EdgeInsets.zero,
          subtitle: Text("substrate_customize_derivation_desc".tr),
          value: algorithm == null,
          onChanged: onChangeCustomDerivation,
        ),
        APPAnimatedSize(
            isActive: algorithm != null,
            onActive: (c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("keypair_type".tr,
                        style: context.textTheme.titleMedium),
                    TextAndLinkView(
                      text: "choose_substrate_key_algorithm_desc".tr,
                      url: LinkConst.reviewSubstrateSignatureSchame,
                      linkDesc: "read_more".tr,
                    ),
                    WidgetConstant.height8,
                    AppDropDownBottom(
                      items: algorithmTypesWidget,
                      label: "keypair_type".tr,
                      onChanged: onChangeAlgorithm,
                      isExpanded: true,
                      value: algorithm,
                    ),
                  ],
                ),
            onDeactive: (c) => WidgetConstant.sizedBox),
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
