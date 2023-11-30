import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/wallet_global_pages.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/account_page.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';

import '../wallet_pages/account_pages/account_pages.dart';

class NetworkAccountPageView extends StatelessWidget {
  const NetworkAccountPageView({super.key, required this.wallet});
  final WalletProvider wallet;
  @override
  Widget build(BuildContext context) {
    if (!wallet.haveAddress) {
      return Padding(
          padding: WidgetConstant.padding20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitleSubtitle(
                title: "setup_bitcoin_address".tr,
                body: Text("setup_bitcoin_address_desc".tr),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FixedElevatedButton(
                      onPressed: () {
                        context.to(PagePathConst.setupBitcoinAddress,
                            argruments: wallet.networkAccount);
                      },
                      child: Text("setup_address".tr)),
                ],
              )
            ],
          ));
    }
    final account = wallet.networkAccount.address;
    return Column(
      children: [
        Container(
          width: context.mediaQuery.size.width,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AddressTextView(
                account: account as IBitcoinAddress,
                onPressed: (p0) {
                  switch (p0) {
                    case 1:
                      context.openSliverBottomSheet(
                          AccountPublicKeyView(
                              address: wallet.networkAccount.address),
                          "publick_key".tr);

                      break;
                    case 0:
                      context.to(PagePathConst.exportPrivateKey,
                          argruments: wallet.networkAccount.address);
                      break;
                    case 2:
                      context.to(PagePathConst.removeAccount,
                          argruments: wallet.networkAccount.address);
                    case 3:
                      context.to(PagePathConst.importAccount,
                          argruments: wallet.network);
                    default:
                  }
                },
              ),
              Padding(
                padding: WidgetConstant.padding20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        CircleAssetsImgaeView(
                          wallet.network.coinParam.logo,
                          radius: 40,
                        ),
                        WidgetConstant.height8,
                        Text(wallet.network.coinParam.coinName,
                            style: context.textTheme.labelLarge),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CoinPriceView(
                            account: wallet.networkAccount.address,
                            style: context.textTheme.titleLarge,
                          ),
                          WidgetConstant.height8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  context.openSliverDialog(
                                      ShareAccountView(
                                        address: wallet.networkAccount.address,
                                      ),
                                      "address_sharing".tr);
                                },
                                heroTag: null,
                                child: const Icon(Icons.download),
                              ),
                              WidgetConstant.width8,
                              FloatingActionButton(
                                heroTag: null,
                                onPressed: () {
                                  context.to(PagePathConst.bitcoinTransaction);
                                },
                                child: const Icon(Icons.upload),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        BitcoinAccountPageView(wallet: wallet),
      ],
    );
  }
}

class _AddressTextView extends StatelessWidget {
  const _AddressTextView({required this.account, required this.onPressed});
  final IBitcoinAddress account;
  final IntVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.mediaQuery.size.width,
        padding: WidgetConstant.padding10,
        decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: WidgetConstant.borderBottom8),
        child: Row(
          children: [
            Expanded(
              child: CopyTextIcon(
                dataToCopy: account.address.toAddress,
                color: context.colors.onPrimary,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.bitcoinAddress.type.value,
                      style: context.textTheme.labelLarge
                          ?.copyWith(color: context.colors.onPrimary),
                    ),
                    if (account.isMultiSigAccounts)
                      Text(
                        "multi_signature".tr,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.onPrimary),
                      ),
                    OneLineTextWidget(
                      account.address.toAddress,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.colors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            FocusScope(
              autofocus: false,
              canRequestFocus: false,
              child: SubmenuButton(
                menuChildren: [
                  if (!account.isMultiSigAccounts)
                    MenuItemButton(
                      trailingIcon: const Icon(Icons.north_east_sharp),
                      onPressed: () {
                        onPressed(0);
                      },
                      child: Text("export_private_key".tr),
                    ),
                  if (!account.isMultiSigAccounts)
                    MenuItemButton(
                      trailingIcon: const Icon(Icons.north_east_sharp),
                      onPressed: () {
                        onPressed(1);
                      },
                      child: Text("export_public_key".tr),
                    ),
                  MenuItemButton(
                    trailingIcon: const Icon(Icons.remove),
                    onPressed: () {
                      onPressed(2);
                    },
                    child: Text("remove_account".tr),
                  ),
                ],
                style: ButtonStyle(
                    iconColor:
                        MaterialStatePropertyAll(context.colors.onPrimary)),
                child: const SizedBox(
                  width: AppGlobalConst.double40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.more_vert_sharp),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
