import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'address_details.dart';

class SwitchOrSelectAccountView extends StatelessWidget {
  const SwitchOrSelectAccountView(
      {super.key,
      required this.account,
      required this.showMultiSig,
      this.isSwitch = false});
  final Chain account;
  final bool showMultiSig;
  final bool isSwitch;
  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<WalletProvider>(
        controller: () => context.watch<WalletProvider>(StateConst.main),
        repositoryId: StateConst.main,
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
                        .replaceOne(wallet.wallet.network.coinParam.token.name),
                    body: Text("setup_network_address_desc".tr.replaceOne(
                        wallet.wallet.network.coinParam.token.name)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FixedElevatedButton(
                          onPressed: () {
                            context.to(PageRouter.setupGenericAddress,
                                argruments: account);
                          },
                          child: Text("setup_address".tr)),
                    ],
                  )
                ],
              ),
            );
          }
          final currentAccount = account.address;
          List<ChainAccount> addresses =
              List<ChainAccount>.from(account.addresses)
                ..sort((a, b) => a == currentAccount ? 0 : 1);
          if (!showMultiSig) {
            addresses = addresses.where((e) => !e.multiSigAccount).toList();
          }

          return ListView.builder(
              itemCount: addresses.length,
              shrinkWrap: true,
              physics: WidgetConstant.noScrollPhysics,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                bool isSelected = false;
                if (isSwitch) {
                  isSelected = addr == currentAccount;
                }
                return ContainerWithBorder(
                  backgroundColor: isSelected
                      ? context.colors.secondary
                      : context.colors.primaryContainer,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isSelected
                              ? null
                              : () {
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
                        isSensitive: false,
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
