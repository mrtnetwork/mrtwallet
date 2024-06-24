import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/account_pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class RippleFeaturePageView extends StatelessWidget {
  const RippleFeaturePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<AppXRPNetwork, IXRPAddress>(
      title: "settings",
      childBulder: (wallet, chain, address, sm, switchAccount) {
        return ConstraintsBoxView(
            child: Column(
          children: [
            AppListTile(
              leading: const Icon(Icons.password),
              title: Text("ripple_key_conversion".tr),
              subtitle: Text("ripple_key_conversion_desc".tr),
              onTap: () {
                context.to(PagePathConst.rippleKeyConversion);
              },
            ),
          ],
        ));
      },
    );
  }
}
