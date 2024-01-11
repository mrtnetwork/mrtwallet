import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/chain/chain.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class BitcoinAccountPageView extends StatelessWidget {
  const BitcoinAccountPageView({super.key, required this.chainAccount});
  final AppChain chainAccount;
  @override
  Widget build(BuildContext context) {
    final apiProvider = chainAccount.provider().serviceProvider;
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    return Column(
      children: [
        AppListTile(
          title: Text("multi_signature".tr),
          subtitle: Text("establishing_multi_sig_addr".tr),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            context.to(PagePathConst.setupBitcoinMultsig);
          },
        ),
        AppListTile(
          title: Text("view_on_explorer".tr),
          subtitle: Text("view_address_on_explorer".tr),
          trailing: const Icon(Icons.open_in_browser),
          onTap: () {
            LunchUri.lunch(chainAccount.network.coinParam.getAccountExplorer(
                chainAccount.account.address.address.toAddress)!);
          },
        ),
        Row(
          children: [
            Expanded(
              child: AppListTile(
                title: Text("api_provider_service".tr),
                subtitle: Text(apiProvider.provider.serviceName),
                onTap: () {
                  context
                      .openSliverDialog<ApiProviderService>(
                          (ctx) => SelectProviderView(
                                network: chainAccount.network,
                                selectedProvider: apiProvider.provider,
                              ),
                          "service_provider".tr)
                      .then(wallet.changeProvider);
                },
              ),
            ),
            Padding(
                padding: WidgetConstant.paddingHorizontal20,
                child: ProviderTrackerStatusView(provider: apiProvider))
          ],
        ),
      ],
    );
  }
}
