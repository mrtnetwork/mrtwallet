import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final CryptoAddress account = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (p0, p1) {
          return _DeleteAccountView(password: p1, account: account);
        },
        title: "remove_account".tr,
        subtitle: PageTitleSubtitle(
            title: "remove_account".tr, body: Text("remove_account_desc".tr)));
  }
}

class _DeleteAccountView extends StatefulWidget {
  const _DeleteAccountView({required this.password, required this.account});
  final String password;
  final CryptoAddress account;

  @override
  State<_DeleteAccountView> createState() => __DeleteAccountViewState();
}

class __DeleteAccountViewState extends State<_DeleteAccountView>
    with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  bool deleted = false;

  void deleteAccount() async {
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    progressKey.progressText("remove_account_pls_wait".tr);
    final result = await model.removeAccount(widget.account);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("account_deleted".tr, backToIdle: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => ConstraintsBoxView(
        padding: WidgetConstant.padding20,
        child: AnimatedSwitcher(
          duration: AppGlobalConst.animationDuraion,
          child: SingleChildScrollView(
            child: deleted
                ? Column(
                    key: const ValueKey<bool>(true),
                    children: [
                      PageTitleSubtitle(
                          title: "b_using_web3_secret_defination".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextAndLinkView(
                                text: "about_web3_secret_defination".tr,
                                url: AppLinkConst.aboutWeb3StorageDefination,
                              ),
                              WidgetConstant.height8,
                              Text("about_web3_defination_desc1".tr),
                              WidgetConstant.height8,
                              Text("backup_desc1".tr),
                              WidgetConstant.height8,
                              Text("backup_desc2".tr)
                            ],
                          )),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitleSubtitle(
                          title: "remove_account".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("remove_account_desc".tr),
                              WidgetConstant.height8,
                              Text("remove_accounts_desc1".tr),
                              WidgetConstant.height8,
                              Text("backup_private_key_desc".tr)
                            ],
                          )),
                      Text("address_details".tr,
                          style: context.textTheme.titleLarge),
                      WidgetConstant.height8,
                      BitcoinAddressDetailsView(
                        account: widget.account as IBitcoinAddress,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: WidgetConstant.paddingVertical20,
                            child: FilledButton.tonalIcon(
                                label: Text("remove_account".tr),
                                onPressed: deleteAccount,
                                icon: Icon(Icons.delete,
                                    color: context.colors.error)),
                          )
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
