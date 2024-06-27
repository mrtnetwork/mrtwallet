import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart' show CryptoCoins;
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show QuickContextAccsess, QuickDateTimeFormater, SafeState, Translate;
import 'package:mrt_wallet/future/wallet/global/global.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart'
    show
        AddressDerivationIndex,
        WalletNetwork,
        Bip32AddressIndex,
        ChainHandler,
        CustomProposal,
        EncryptedCustomKey;

typedef _OnGenerateDerivation = Future<Bip32AddressIndex?> Function();

class SetupDerivationModeView extends StatefulWidget {
  final CryptoCoins coin;
  final ChainHandler chainAccout;
  final AddressDerivationIndex? defaultDerivation;
  final Widget? title;
  final List<EncryptedCustomKey> customKeys;
  const SetupDerivationModeView(
      {super.key,
      required this.coin,
      required this.chainAccout,
      required this.customKeys,
      this.defaultDerivation,
      this.title});

  @override
  State<SetupDerivationModeView> createState() =>
      _SetupDerivationModeView2State();
}

class _SetupDerivationModeView2State extends State<SetupDerivationModeView>
    with SafeState {
  EncryptedCustomKey? selectedCustomKey;
  WalletNetwork get network => chainAccount.network;
  ChainHandler get chainAccount => widget.chainAccout;
  late final bool useByronLegacyDeriavation =
      widget.coin.proposal == CustomProposal.cip0019;

  AddressDerivationIndex derivationkey(CryptoCoins coin) {
    if (selectedCustomKey != null) {
      return (customKeyIndex ??
              Bip32AddressIndex(currencyCoin: selectedCustomKey?.coin ?? coin))
          .copyWith(importedKeyId: selectedCustomKey!.id);
    }
    return customKeyIndex ?? nextDerivation;
  }

  AddressDerivationIndex get nextDerivation {
    if (widget.defaultDerivation != null) {
      return widget.defaultDerivation!;
    }
    final nextDerive =
        chainAccount.account.nextDerive(selectedCustomKey?.coin ?? widget.coin);
    return nextDerive;
  }

  void onChangeCustomKey(EncryptedCustomKey? newSelected) {
    selectedCustomKey = newSelected;
    setState(() {});
  }

  List<EncryptedCustomKey> get customKeys => widget.customKeys;
  bool get derivationStandard => customKeyIndex == null;
  Bip32AddressIndex? customKeyIndex;

  void onChangeDerivation(_OnGenerateDerivation onGenerateDerivation) async {
    if (derivationStandard) {
      customKeyIndex = await onGenerateDerivation();
    } else {
      customKeyIndex = null;
    }
    setState(() {});
  }

  void onSubmit() {
    final key = derivationkey(widget.coin);
    context.pop(key);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title ??
            PageTitleSubtitle(
                title: "derive_network_address"
                    .tr
                    .replaceOne(network.coinParam.token.name),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("disable_standard_derivation".tr)],
                )),
        Text(
          "derivation_path".tr,
          style: context.textTheme.titleMedium,
        ),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemove: () {
              onChangeDerivation(
                () async {
                  if (useByronLegacyDeriavation) {
                    return context.openSliverBottomSheet<Bip32AddressIndex>(
                        "key_derivation".tr,
                        child: ByronLegacyKeyDerivationView(
                          coin: widget.coin,
                          curve: widget.coin.conf.type,
                        ));
                  }
                  return context.openSliverBottomSheet<Bip32AddressIndex>(
                      "key_derivation".tr,
                      child: Bip32KeyDerivationView(
                        coin: selectedCustomKey?.coin ?? widget.coin,
                        curve: selectedCustomKey?.coin.conf.type ??
                            widget.coin.conf.type,
                        network: network,
                        defaultPath: nextDerivation.hdPath,
                      ));
                },
              );
            },
            onRemoveIcon: derivationStandard
                ? const Icon(Icons.edit)
                : const Icon(Icons.remove_circle),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectedCustomKey == null
                    ? Text(
                        derivationStandard
                            ? "standard_derivation".tr
                            : "custom_derivation".tr,
                        style: context.textTheme.labelLarge,
                      )
                    : Text(
                        customKeyIndex == null
                            ? "non_derivation".tr
                            : "custom_derivation".tr,
                        style: context.textTheme.labelLarge,
                      ),
                selectedCustomKey == null
                    ? Text(
                        customKeyIndex?.toString() ?? nextDerivation.toString(),
                      )
                    : Text(
                        customKeyIndex?.toString() ??
                            "import_key_derivation_desc2".tr,
                      )
              ],
            )),
        WidgetConstant.height20,
        Text(
          "select_creation_type".tr,
          style: context.textTheme.titleMedium,
        ),
        Text("generate_from_hd_wallet".tr),
        WidgetConstant.height8,
        RadioListTile<EncryptedCustomKey?>(
          value: null,
          groupValue: selectedCustomKey,
          onChanged: onChangeCustomKey,
          title: Text("hd_wallet".tr),
          subtitle: Text("generate_from_hd_wallet".tr),
        ),
        Column(
          children: List.generate(customKeys.length, (index) {
            final key = customKeys[index];
            return RadioListTile(
              value: key,
              groupValue: selectedCustomKey,
              onChanged: onChangeCustomKey,
              title: OneLineTextWidget(key.networkPubKey(network)),
              subtitle: RichText(
                  text:
                      TextSpan(style: context.textTheme.bodyMedium, children: [
                if (key.name != null) ...[
                  TextSpan(text: key.name),
                  TextSpan(
                      text: " (${key.created.toDateAndTime()}) ",
                      style: context.textTheme.bodySmall)
                ] else
                  TextSpan(
                      text: "imported_at".tr.replaceOne(key.created.toString()),
                      style: context.textTheme.bodyMedium),
              ])),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: onSubmit,
              child: Text("generate_address".tr),
            )
          ],
        )
      ],
    );
  }
}
