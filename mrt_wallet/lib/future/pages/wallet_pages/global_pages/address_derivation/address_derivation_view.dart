import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_derivation/generic.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'controller.dart';

class NetworkGenericAddressDerivationView extends StatelessWidget {
  const NetworkGenericAddressDerivationView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    return MrtViewBuilder<AddressDerivationController>(
      controller: () => AddressDerivationController(
          chainAccount: wallet.chain, network: wallet.network, wallet: wallet),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text("setup_address".tr),
        ),
        body: PageProgress(
          key: controller.pageProgressKey,
          backToIdle: AppGlobalConst.oneSecoundDuration,
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
                        duration: AppGlobalConst.animationDuraion,
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
