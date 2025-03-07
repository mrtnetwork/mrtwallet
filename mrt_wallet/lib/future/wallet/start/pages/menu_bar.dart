import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/network.dart';
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
  const AccountAppbarPopupMenu(this.wallet, {super.key});
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
            case 8:
              context.to(PageRouter.multisigAccountInfo(chain.network.type),
                  argruments: chain);
              break;
            case 4:
              final accountUrl = chain.network
                  .getAccountExplorer(chain.address.address.toAddress);
              UriUtils.lunch(accountUrl);
              break;
            case 5:
              UriUtils.lunch(chain.network.coinParam.marketUri!);
              break;
            case 7:
              context.openSliverDialog<bool>((context) {
                return DialogTextView(
                    widget: const _RemoveChainDialog(),
                    buttonWidget: DialogDoubleButtonView());
              }, 'remove_network'.tr).then((v) {
                if (v != true) return;
                wallet.wallet.removeChain(chain);
              });
              break;
            case 6:
              context.to(PageRouter.updateNetwork);
              break;
            default:
          }
        },
        itemBuilder: (context) {
          final accountUrl =
              chain.network.getAccountExplorer(chain.address.address.toAddress);
          return [
            ..._chainCustomButton(chain: chain, context: context, value: 20),
            if (!chain.address.multiSigAccount)
              PopupMenuItem<int>(
                value: 0,
                child: AppListTile(
                  trailing: const Icon(Icons.north_east_sharp),
                  title: Text("export_private_key".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
            if (!chain.address.multiSigAccount)
              PopupMenuItem<int>(
                value: 1,
                child: AppListTile(
                  trailing: const Icon(Icons.north_east_sharp),
                  title: Text("export_public_key".tr,
                      style: context.textTheme.labelMedium),
                ),
              )
            else if (chain.address.iAddressType.isMultisigByPublicKey)
              PopupMenuItem<int>(
                value: 8,
                child: AppListTile(
                  trailing: const Icon(Icons.north_east_sharp),
                  title: Text("multisig_address_infos".tr,
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
                      style: context.textTheme.labelMedium)),
            ),
            if (accountUrl != null)
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
                      CircleAssetsImageView(CoinGeckoUtils.logo, radius: 12),
                  title: Text("CoinGecko".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
            PopupMenuItem<int>(
              value: 6,
              child: AppListTile(
                  trailing: const Icon(Icons.edit),
                  title: Text("update_network".tr,
                      style: context.textTheme.labelMedium)),
            ),
            if (chain.network.isImportedNetwork) ...[
              PopupMenuItem<int>(
                value: 7,
                child: AppListTile(
                  trailing: const Icon(Icons.remove),
                  title: Text("remove_network".tr,
                      style: context.textTheme.labelMedium),
                ),
              ),
            ],
          ];
        });
  }
}

List<PopupMenuItem<int>> _chainCustomButton(
    {required Chain chain, required BuildContext context, required int value}) {
  return switch (chain.network.type) {
    NetworkType.cardano => cardanoAccountMenuButton(
        chain: chain.cast(), context: context, value: value),
    _ => []
  };
}

class _RemoveChainDialog extends StatelessWidget {
  const _RemoveChainDialog();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("remove_network_desc2".tr, style: context.textTheme.titleMedium),
        Text("remove_network_desc".tr),
      ],
    );
  }
}
