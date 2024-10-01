import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart' show Chain, WalletNetwork;
import 'package:mrt_wallet/crypto/worker.dart';

typedef _OnGenerateDerivation = Future<AddressDerivationIndex?> Function();

class SetupDerivationModeView extends StatefulWidget {
  final CryptoCoins coin;
  final List<CryptoCoins> networkCoins;
  final Chain chainAccout;
  final AddressDerivationIndex? defaultDerivation;
  final Widget? title;
  final List<EncryptedCustomKey> customKeys;
  final SeedTypes seedGenerationType;
  const SetupDerivationModeView(
      {super.key,
      required this.coin,
      required this.chainAccout,
      required this.customKeys,
      this.networkCoins = const [],
      this.defaultDerivation,
      this.title,
      required this.seedGenerationType});

  @override
  State<SetupDerivationModeView> createState() =>
      _SetupDerivationModeView2State();
}

class _SetupDerivationModeView2State extends State<SetupDerivationModeView>
    with SafeState {
  EncryptedCustomKey? selectedCustomKey;
  WalletNetwork get network => chainAccount.network;
  Chain get chainAccount => widget.chainAccout;
  late CryptoCoins coin = widget.coin;
  late final bool useByronLegacyDeriavation =
      coin.proposal == CustomProposal.cip0019;

  AddressDerivationIndex derivationkey(CryptoCoins coin) {
    if (selectedCustomKey != null) {
      final keyIndex = (customKeyIndex ??
          Bip32AddressIndex(
              currencyCoin: coin, seedGeneration: widget.seedGenerationType));
      return keyIndex.asImportedKey(selectedCustomKey!.id);
    }
    return customKeyIndex ?? nextDerivation;
  }

  AddressDerivationIndex get nextDerivation {
    if (widget.defaultDerivation != null) {
      return widget.defaultDerivation!;
    }
    final nextDerive = chainAccount.nextDerive(coin, widget.seedGenerationType);
    return nextDerive;
  }

  void onChangeCustomKey(EncryptedCustomKey? newSelected) {
    if (newSelected == null) {
      selectedCustomKey = null;
      coin = widget.coin;
    } else {
      bool canUseKey = false;
      coin = widget.coin;
      if (newSelected.coin.conf.type == coin.conf.type) {
        selectedCustomKey = newSelected;
        canUseKey = true;
      } else {
        CryptoCoins? findCoin = MethodUtils.nullOnException(() =>
            widget.networkCoins.firstWhere(
                (element) => element.conf.type == newSelected.coin.conf.type));
        findCoin ??= coin;
        if (newSelected.coin.conf.type == findCoin.conf.type) {
          selectedCustomKey = newSelected;
          coin = findCoin;
          canUseKey = true;
        }
      }
      if (!canUseKey) {
        context.showAlert("unsuported_key".tr);
      }
    }
    setState(() {});
  }

  List<EncryptedCustomKey> get customKeys => widget.customKeys;
  bool get derivationStandard => customKeyIndex == null;
  AddressDerivationIndex? customKeyIndex;

  void onChangeDerivation(_OnGenerateDerivation onGenerateDerivation) async {
    if (derivationStandard) {
      customKeyIndex = await onGenerateDerivation();
    } else {
      customKeyIndex = null;
    }
    setState(() {});
  }

  void onSubmit() {
    final key = derivationkey(coin);
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
                            coin: coin, curve: coin.conf.type));
                  }
                  return context.openSliverBottomSheet<AddressDerivationIndex>(
                      "key_derivation".tr,
                      child: Bip32KeyDerivationView(
                          coin: coin,
                          curve: coin.conf.type,
                          network: network,
                          defaultPath: nextDerivation.hdPath,
                          seedGeneration: widget.seedGenerationType));
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
                    ? AddressDrivationInfo(customKeyIndex ?? nextDerivation)
                    : customKeyIndex != null
                        ? AddressDrivationInfo(customKeyIndex ?? nextDerivation)
                        : Text("import_key_derivation_desc2".tr)
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
              title: OneLineTextWidget(key.publicKey),
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
              padding: WidgetConstant.paddingVertical40,
              onPressed: onSubmit,
              child: Text("generate_address".tr),
            )
          ],
        )
      ],
    );
  }
}
