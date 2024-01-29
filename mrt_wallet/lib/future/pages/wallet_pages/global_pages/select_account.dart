import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class SwitchOrSelectAccountView extends StatelessWidget {
  const SwitchOrSelectAccountView({
    super.key,
    required this.account,
    this.currentAddress,
    required this.showMultiSig,
  });
  final NetworkAccountCore account;
  final CryptoAccountAddress? currentAddress;
  final bool showMultiSig;
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
          final currentAccount = currentAddress ?? account.address;
          final addresses = List<CryptoAccountAddress>.from(account.addresses)
            ..sort((a, b) => a == currentAccount ? 0 : 1);

          return ListView.builder(
              itemCount: addresses.length,
              shrinkWrap: true,
              physics: WidgetConstant.noScrollPhysics,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                final bool isSelected = addr == currentAccount;
                if (!showMultiSig && addr.multiSigAccount) {
                  return WidgetConstant.sizedBox;
                }
                return ContainerWithBorder(
                  backgroundColor: isSelected
                      ? context.colors.secondary
                      : context.colors.primaryContainer,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (context.mounted) {
                              context.pop(addr);
                            }
                          },
                          child: AddressDetailsView(
                              address: addr,
                              color: isSelected
                                  ? context.colors.onSecondary
                                  : context.colors.onPrimaryContainer),
                        ),
                      ),
                      WidgetConstant.width8,
                      CopyTextIcon(
                        dataToCopy: addr.address.toAddress,
                        color: isSelected
                            ? context.colors.onSecondary
                            : context.colors.onPrimaryContainer,
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
