import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst, StateConst;
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/address/setup_address.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/address/setup_address_page.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class NetworkGenericAddressDerivationView extends StatelessWidget {
  const NetworkGenericAddressDerivationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Chain chain = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.unlock,
        onAccsess: (crendential, password, _) {
          switch (chain.network.type) {
            case NetworkType.bitcoinAndForked:
            case NetworkType.bitcoinCash:
              return SetupBitcoinAddressView(chain.cast());
            case NetworkType.cardano:
              return SetupCardanoAddressView(chain.cast());
            case NetworkType.cosmos:
              return _NetworkGenericAddressDerivationView<CosmosBaseAddress,
                  ICosmosAddress>(chain.cast());
            case NetworkType.ethereum:
              return _NetworkGenericAddressDerivationView<ETHAddress,
                  IEthAddress>(chain.cast());
            case NetworkType.tron:
              return _NetworkGenericAddressDerivationView<TronAddress,
                  ITronAddress>(chain.cast());
            case NetworkType.polkadot:
            case NetworkType.kusama:
              return _NetworkGenericAddressDerivationView<SubstrateAddress,
                  ISubstrateAddress>(chain.cast());
            case NetworkType.xrpl:
              return _NetworkGenericAddressDerivationView<XRPAddress,
                  IXRPAddress>(chain.cast());
            case NetworkType.ton:
              return _NetworkGenericAddressDerivationView<TonAddress,
                  ITonAddress>(chain.cast());
            case NetworkType.solana:
              return _NetworkGenericAddressDerivationView<SolAddress,
                  ISolanaAddress>(chain.cast());
            case NetworkType.stellar:
              return _NetworkGenericAddressDerivationView<StellarAddress,
                  IStellarAddress>(chain.cast());
            default:
              throw UnimplementedError();
          }
        },
        title: "setup_address".tr,
        subtitle: PageTitleSubtitle(
            title: "unlock_wallet".tr, body: Text("unlock_access_desc".tr)));
  }
}

class _NetworkGenericAddressDerivationView<NETWORKADDRESS,
        CHAINACCOUNT extends NETWORKCHAINACCOUNT<NETWORKADDRESS>>
    extends StatelessWidget {
  const _NetworkGenericAddressDerivationView(this.chain);
  final APPCHAINACCOUNT<CHAINACCOUNT> chain;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return MrtViewBuilder<
        AddressDerivationController<NETWORKADDRESS, CHAINACCOUNT>>(
      controller: () =>
          AddressDerivationController<NETWORKADDRESS, CHAINACCOUNT>(
              chain: chain, wallet: wallet),
      repositoryId: StateConst.addressDerivation,
      builder: (controller) => PageProgress(
        key: controller.pageProgressKey,
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: PageProgressStatus.idle,
        child: (c) => Center(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              WidgetConstant.sliverPaddingVertial20,
              SliverToBoxAdapter(
                  child: ConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                child: Form(
                  key: controller.form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "setup_network_address".tr.replaceOne(
                              controller.network.coinParam.token.name),
                          body: LargeTextView(
                            [
                              "disable_standard_derivation_desc".tr,
                              "setup_address_derivation_keys_desc".tr,
                              "please_following_steps_to_generate_address".tr,
                              "custom_path_derivation_desc".tr,
                              if (controller.network.type == NetworkType.ton)
                                "ton_mnemonic_feature_desc".tr
                            ],
                          )),
                      SetupGenericAddressView(controller: controller)
                    ],
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
