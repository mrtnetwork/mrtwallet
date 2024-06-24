import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/account_pages/account_controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class TonSettingsView extends StatelessWidget {
  const TonSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<APPTonNetwork, ITonAddress>(
      title: "settings",
      childBulder: (wallet, chain, address, sm, switchAccount) {
        return ConstraintsBoxView(
            child: Column(
          children: [
            AppListTile(
              leading: const Icon(Icons.password),
              title: Text("ton_mnemonic".tr),
              subtitle: Text("generate_ton_private_key".tr),
              onTap: () {
                context.to(PagePathConst.tonMnemonic);
              },
            ),
          ],
        ));
      },
    );
  }
}
