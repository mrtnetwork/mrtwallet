import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPConst, MrtViewBuilder, StateConst, Translate, QuickContextAccsess;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart' show NetworkType;

class NetworkGenericAddressDerivationView extends StatelessWidget {
  const NetworkGenericAddressDerivationView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    return MrtViewBuilder<AddressDerivationController>(
      controller: () => AddressDerivationController(
          chainAccount: wallet.chain, network: wallet.network, wallet: wallet),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text("setup_address".tr),
        ),
        body: PageProgress(
          key: controller.pageProgressKey,
          backToIdle: APPConst.oneSecoundDuration,
          initialStatus: PageProgressStatus.idle,
          child: () => UnfocusableChild(
            child: Center(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    child: AnimatedSwitcher(
                        duration: APPConst.animationDuraion,
                        child: Form(
                          key: controller.form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            key: const ValueKey<bool>(true),
                            children: [
                              PageTitleSubtitle(
                                  title: "setup_network_address".tr.replaceOne(
                                      controller.network.coinParam.token.name),
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("disable_standard_derivation".tr),
                                      WidgetConstant.height8,
                                      Text("setup_address_derivation_keys_desc"
                                          .tr),
                                      WidgetConstant.height8,
                                      Text(
                                          "please_following_steps_to_generate_address"
                                              .tr),
                                      if (controller.network.type ==
                                          NetworkType.ton) ...[
                                        WidgetConstant.height8,
                                        Text("ton_mnemonic_feature_desc".tr),
                                      ]
                                    ],
                                  )),
                              SetupGenericAddressView(controller: controller)
                            ],
                          ),
                        )),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
