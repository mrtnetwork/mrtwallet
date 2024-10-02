import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/router/page_router.dart';

class StellarFeaturePageView extends StatelessWidget {
  const StellarFeaturePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<StellarChain>(
      title: "settings".tr,
      childBulder: (wallet, chain, switchAccount) {
        return ConstraintsBoxView(
            child: Column(
          children: [
            AppListTile(
              leading: const Icon(Icons.password),
              title: Text("stellar_key_conversion".tr),
              subtitle: Text("stellar_key_conversion_desc".tr),
              onTap: () {
                context.to(PageRouter.stellarKeyConversion);
              },
            ),
          ],
        ));
      },
    );
  }
}
