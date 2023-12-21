import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/page_path.dart';
import 'package:mrt_wallet/app/constant/state_ids.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';

class SwitchOrSelectAccountView extends StatelessWidget {
  const SwitchOrSelectAccountView(
      {super.key, required this.account, this.currentAddress});
  final NetworkAccountCore account;
  final CryptoAccountAddress? currentAddress;
  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
        controller: () => context.watch<WalletProvider>(StateIdsConst.main),
        removable: false,
        builder: (wallet) {
          if (!account.haveAddress) {
            return Padding(
              padding: WidgetConstant.padding20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitleSubtitle(
                    title: "setup_network_address"
                        .tr
                        .replaceOne(wallet.network.coinParam.token.name),
                    body: Text("setup_network_address_desc"
                        .tr
                        .replaceOne(wallet.network.coinParam.token.name)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          onPressed: () {
                            context.to(
                                PagePathConst.setupAddressPage(account.network),
                                argruments: account);
                          },
                          child: Text("setup_address".tr)),
                    ],
                  )
                ],
              ),
            );
          }
          final addresses = account.addresses;
          final currentAccount = currentAddress ?? account.address;

          return ListView.builder(
              itemCount: addresses.length,
              shrinkWrap: true,
              physics: WidgetConstant.noScrollPhysics,
              itemBuilder: (context, index) {
                final bool isSelected = addresses[index] == currentAccount;
                return ContainerWithBorder(
                  shadow: isSelected,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (context.mounted) {
                              context.pop(addresses[index]);
                            }
                          },
                          child: AddressDetailsView(
                              address: addresses[index],
                              isSelected: addresses[index] == currentAccount),
                        ),
                      ),
                      WidgetConstant.width8,
                      CopyTextIcon(
                          dataToCopy: addresses[index].address.toAddress),
                    ],
                  ),
                );
              });
        });
  }
}
