import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class AccountMenuButtonView extends StatelessWidget {
  const AccountMenuButtonView({super.key, required this.wallet});
  final WalletProvider wallet;
  Chain get chain => wallet.wallet.chain;
  ChainAccount get account => chain.address;

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
            CircleTokenImageView(chain.network.token, radius: 30),
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
                      Text("multi_signature".tr,
                          style: context.textTheme.bodyMedium),
                    OneLineTextWidget(
                      account.address.toAddress,
                      style: context.textTheme.bodyMedium,
                    ),
                    CoinPriceView(
                      account: chain.address,
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
  Chain get chain => wallet.wallet.chain;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        tooltip: "account_options".tr,
        constraints: WidgetConstant.constraintsMinWidth200,
        onSelected: (v) {
          switch (v) {
            case 0:
              context.to(PageRouter.exportPrivateKey,
                  argruments: chain.address);
              break;
            case 1:
              context.to(PageRouter.showPublicKey, argruments: chain.address);
              break;
            case 2:
              final account = chain;
              final address = chain.address;
              context
                  .openSliverBottomSheet<String>(
                    "account_name".tr,
                    child: StringWriterView(
                      defaultValue: address.accountName,
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
                  .then((value) => wallet.wallet.setupAccountName(
                      name: value, account: account, address: address));
              break;
            case 3:
              context.to(PageRouter.removeAccount, argruments: chain);
              break;
            case 4:
              UriUtils.lunch(chain.network.coinParam
                  .getAccountExplorer(chain.address.address.toAddress));
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
                  trailing:
                      CircleAssetsImgaeView(CoinGeckoUtils.logo, radius: 12),
                  title: Text("CoinGecko".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
          ];
        });
  }
}
