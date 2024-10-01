import 'package:blockchain_utils/bip/bip/conf/core/coins.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/address/pages/setup_address.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/stellar.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/address/setup_address.dart';
import 'package:mrt_wallet/future/wallet/network/ton/address/address.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'controller.dart';

class SetupGenericAddressView extends StatelessWidget {
  const SetupGenericAddressView({super.key, required this.controller});
  final AddressDerivationController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.network.type) {
      case NetworkType.xrpl:
        return SetupRippleAddressView(controller: controller);
      case NetworkType.stellar:
        return SetupStellarAddressView(controller: controller);
      case NetworkType.ton:
        return SetupTonAddressView(controller: controller);
      case NetworkType.polkadot:
      case NetworkType.kusama:
        return SetupSubstrateAddressView(controller: controller);
      default:
        return _GenericNetworkAddressGenerationView(controller: controller);
    }
  }
}

class _GenericNetworkAddressGenerationView extends StatelessWidget {
  const _GenericNetworkAddressGenerationView({required this.controller});
  final AddressDerivationController controller;
  static NewAccountParams getnerateAccoutParams(
      Bip32AddressIndex keyIndex, WalletNetwork network, CryptoCoins coin) {
    switch (network.type) {
      case NetworkType.ethereum:
        return EthereumNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.solana:
        return SolanaNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.cosmos:
        return CosmosNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.tron:
        return TronNewAddressParams(deriveIndex: keyIndex, coin: coin);
      default:
        throw UnimplementedError();
    }
  }

  static void generateAddress(
      BuildContext context, AddressDerivationController controller) async {
    final keyIndex = await controller.getCoin(
        context: context, seedGeneration: SeedTypes.bip39);
    if (keyIndex == null || !keyIndex.isBip32) return;
    final newAccountParam = getnerateAccoutParams(
        keyIndex as Bip32AddressIndex, controller.network, controller.coin);
    controller.generateAddress(newAccountParam);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FixedElevatedButton(
          padding: WidgetConstant.paddingVertical20,
          onPressed: () {
            generateAddress(context, controller);
          },
          child: Text("generate_address".tr),
        ),
      ],
    );
  }
}
