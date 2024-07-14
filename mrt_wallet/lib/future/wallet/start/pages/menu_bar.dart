import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class AccountMenuButtonView extends StatelessWidget {
  const AccountMenuButtonView({super.key, required this.wallet});
  final WalletProvider wallet;
  ChainHandler get chain => wallet.chain;
  CryptoAddress get account => chain.account.address;

  @override
  Widget build(BuildContext context) {
    final bool hasAccountNameOrType =
        account.accountName != null || account.type != null;
    final bool showMultiSig = account.multiSigAccount && !hasAccountNameOrType;
    return SizedBox(
      height: 90,
      child: Padding(
        padding: WidgetConstant.paddingHorizontal10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleTokenImgaeView(chain.network.coinParam.token, radius: 30),
            WidgetConstant.width8,
            Expanded(
              child: CopyTextIcon(
                dataToCopy: account.address.toAddress,
                isSensitive: false,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasAccountNameOrType)
                      account.accountName != null
                          ? RichText(
                              maxLines: 1,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: account.accountName,
                                    style: context.textTheme.labelLarge),
                                if (account.type != null)
                                  TextSpan(
                                      text: " (${account.type!.tr})",
                                      style: context.textTheme.bodySmall)
                              ]))
                          : Text(
                              account.accountName ?? account.type!.tr,
                              style: context.textTheme.labelLarge,
                            ),
                    if (showMultiSig)
                      Text(
                        "multi_signature".tr,
                        style: context.textTheme.bodyMedium,
                      ),
                    OneLineTextWidget(
                      account.address.toAddress,
                      style: context.textTheme.bodyMedium,
                    ),
                    CoinPriceView(
                      account: chain.account.address,
                      style: context.textTheme.titleMedium,
                      token: chain.network.coinParam.token,
                      enableMarketPrice: true,
                    ),
                  ],
                ),
              ),
            ),
            AccountAppbarPopupMenu(wallet)
          ],
        ),
      ),
    );
  }
}

class AccountAppbarPopupMenu extends StatelessWidget {
  const AccountAppbarPopupMenu(this.wallet, {Key? key}) : super(key: key);
  final WalletProvider wallet;
  ChainHandler get chain => wallet.chain;
  CryptoAddress get account => chain.account.address;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        tooltip: "account_options".tr,
        onSelected: (v) {
          switch (v) {
            case 0:
              context.to(PageRouter.exportPrivateKey,
                  argruments: wallet.chain.account.address);
              break;
            case 1:
              context.to(PageRouter.showPublicKey,
                  argruments: wallet.chain.account.address);
              break;
            case 2:
              context
                  .openSliverBottomSheet<String>(
                    "account_name".tr,
                    child: StringWriterView(
                      defaultValue: wallet.chain.account.address.accountName,
                      regExp: APPConst.accountNameRegExp,
                      title: PageTitleSubtitle(
                          title: "setup_or_update_account_name".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("setup_or_update_account_name".tr),
                              WidgetConstant.height8,
                              Text("remove_account_name_desc".tr),
                            ],
                          )),
                      buttonText: "setup_input".tr,
                      label: "account_name".tr,
                    ),
                  )
                  .then((value) => wallet.setupAccountName(
                      value, wallet.chain.account.address));
              break;
            case 3:
              context.to(PageRouter.removeAccount,
                  argruments: wallet.chain.account.address);
              break;
            case 4:
              UriUtils.lunch(chain.network.coinParam
                  .getAccountExplorer(account.address.toAddress));
              break;
            case 5:
              UriUtils.lunch(chain.network.coinParam.marketUri!);
              break;
            default:
          }
        },
        itemBuilder: (c) {
          return [
            PopupMenuItem<int>(
              value: 0,
              child: AppListTile(
                trailing: const Icon(Icons.north_east_sharp),
                title: Text("export_private_key".tr,
                    style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: AppListTile(
                trailing: const Icon(Icons.north_east_sharp),
                title: Text("export_public_key".tr,
                    style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: AppListTile(
                trailing: const Icon(Icons.edit),
                title: Text("account_name".tr,
                    style: context.textTheme.labelMedium),
              ),
            ),
            PopupMenuItem<int>(
              value: 3,
              child: AppListTile(
                trailing: const Icon(Icons.remove),
                title: Text("remove_account".tr,
                    style: context.textTheme.labelMedium),
              ),
            ),
            if (chain.network.coinParam.hasAccountExplorer)
              PopupMenuItem<int>(
                value: 4,
                child: AppListTile(
                  trailing: const Icon(Icons.open_in_new),
                  title: Text("view_on_explorer".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
            if (chain.network.coinParam.hasMarketUrl)
              PopupMenuItem<int>(
                value: 5,
                child: AppListTile(
                  trailing: const CircleAssetsImgaeView(CoinGeckoUtils.logo,
                      radius: 12),
                  title: Text("CoinGecko".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
          ];
        });
  }
}
