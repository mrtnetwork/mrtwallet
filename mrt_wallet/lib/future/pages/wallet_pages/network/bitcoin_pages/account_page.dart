import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/extention/extention.dart';
import 'package:mrt_wallet/app/utility/utility.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/provider_tracker_status_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/select_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class BitcoinAccountPageView extends StatelessWidget {
  const BitcoinAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    final apiProvider = wallet.currentProvider(wallet.network);
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
            LunchUri.lunch(wallet.network.coinParam.getAccountExplorer(
                wallet.networkAccount.address.address.toAddress));
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
                          SelectProviderView(
                            network: wallet.network,
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
