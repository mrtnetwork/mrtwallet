import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart' show CryptoCoins;
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show Translate;
import 'package:mrt_wallet/future/wallet/network/ripple/address/pages/setup_address.dart';
import 'package:mrt_wallet/future/wallet/network/ton/address/address.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart'
    show
        WalletNetwork,
        Bip32AddressIndex,
        CosmosNewAddressParams,
        EthereumNewAddressParam,
        NetworkType,
        NewAccountParams,
        SolanaNewAddressParam,
        TronNewAddressParam;

import 'controller.dart';

class SetupGenericAddressView extends StatelessWidget {
  const SetupGenericAddressView({super.key, required this.controller});
  final AddressDerivationController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.network.type) {
      case NetworkType.xrpl:
        return SetupRippleAddressView(controller: controller);
      case NetworkType.ton:
        return SetupTonAddressView(controller: controller);
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
        return EthereumNewAddressParam(deriveIndex: keyIndex, coin: coin);
      case NetworkType.solana:
        return SolanaNewAddressParam(deriveIndex: keyIndex, coin: coin);
      case NetworkType.cosmos:
        return CosmosNewAddressParams(deriveIndex: keyIndex, coin: coin);
      case NetworkType.tron:
        return TronNewAddressParam(deriveIndex: keyIndex, coin: coin);
      default:
        throw UnimplementedError();
    }
  }

  static void generateAddress(
      BuildContext context, AddressDerivationController controller) async {
    final keyIndex = await controller.getCoin(context);
    if (keyIndex == null) return;
    final newAccountParam =
        getnerateAccoutParams(keyIndex, controller.network, controller.coin);
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
