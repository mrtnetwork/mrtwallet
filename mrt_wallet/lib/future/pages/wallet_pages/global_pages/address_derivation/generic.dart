import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation/controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/setup_address.dart';
import 'package:mrt_wallet/future/widgets/button.dart';
import 'package:mrt_wallet/future/widgets/widget_constant.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SetupGenericAddressView extends StatelessWidget {
  const SetupGenericAddressView({super.key, required this.controller});
  final AddressDerivationController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.network.runtimeType) {
      case AppXRPNetwork:
        return SetupRippleAddressView(
          controller: controller,
        );
      default:
        return _GenericNetworkAddressGenerationView(controller: controller);
    }
  }
}

class _GenericNetworkAddressGenerationView extends StatelessWidget {
  const _GenericNetworkAddressGenerationView({required this.controller});
  final AddressDerivationController controller;
  static NewAccountParams getnerateAccoutParams(
      Bip32AddressIndex keyIndex, AppNetworkImpl network) {
    switch (network.runtimeType) {
      case APPEVMNetwork:
        return EthereumNewAddressParam(deriveIndex: keyIndex);
      case APPSolanaNetwork:
        return SolanaNewAddressParam(deriveIndex: keyIndex);
      case APPCosmosNetwork:
        return CosmosNewAddressParams(deriveIndex: keyIndex);
      case APPTVMNetwork:
        return TronNewAddressParam(deriveIndex: keyIndex);
      default:
        throw UnimplementedError();
    }
  }

  static void generateAddress(
      BuildContext context, AddressDerivationController controller) async {
    final keyIndex = await controller.getCoin(context);
    if (keyIndex == null) return;
    final newAccountParam = getnerateAccoutParams(keyIndex, controller.network);
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
