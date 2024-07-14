import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPConst, MrtViewBuilder, StateConst, Translate, QuickContextAccsess;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/address/setup_address.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/address/setup_address_page.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';

class NetworkGenericAddressDerivationView extends StatelessWidget {
  const NetworkGenericAddressDerivationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.unlock,
        onAccsess: (crendential, password, network) {
          switch (network.type) {
            case NetworkType.bitcoinAndForked:
            case NetworkType.bitcoinCash:
              return const SetupBitcoinAddressView();
            case NetworkType.cardano:
              return const SetupCardanoAddressView();
            default:
              return const _NetworkGenericAddressDerivationView();
          }
        },
        title: "setup_address".tr,
        subtitle: PageTitleSubtitle(
            title: "unlock_wallet".tr, body: Text("unlock_access_desc".tr)));
  }
}

class _NetworkGenericAddressDerivationView extends StatelessWidget {
  const _NetworkGenericAddressDerivationView();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return MrtViewBuilder<AddressDerivationController>(
      controller: () => AddressDerivationController(
          chainAccount: wallet.chain, network: wallet.network, wallet: wallet),
      builder: (controller) => PageProgress(
        key: controller.pageProgressKey,
        backToIdle: APPConst.oneSecoundDuration,
        initialStatus: PageProgressStatus.idle,
        child: () => Center(
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
