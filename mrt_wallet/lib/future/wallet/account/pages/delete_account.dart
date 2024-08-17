import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst, LinkConst, StateConst;
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final Chain account = context.getArgruments();
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _DeleteAccountView(password: password, account: account);
        },
        title: "remove_account".tr,
        subtitle: PageTitleSubtitle(
            title: "remove_account".tr, body: Text("remove_account_desc".tr)));
  }
}

class _DeleteAccountView extends StatefulWidget {
  const _DeleteAccountView({required this.password, required this.account});
  final String password;
  final Chain account;

  @override
  State<_DeleteAccountView> createState() => __DeleteAccountViewState();
}

class __DeleteAccountViewState extends State<_DeleteAccountView>
    with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  bool deleted = false;

  void deleteAccount(bool? accept) async {
    if (accept != true) return;
    final model = context.watch<WalletProvider>(StateConst.main);
    progressKey.progressText("remove_account_pls_wait".tr);
    final result = await model.wallet.removeAccount(
        account: widget.account, address: widget.account.address);
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
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => ConstraintsBoxView(
        padding: WidgetConstant.padding20,
        child: AnimatedSwitcher(
          duration: APPConst.animationDuraion,
          child: SingleChildScrollView(
            child: deleted || !widget.account.haveAddress
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
                                url: LinkConst.aboutWeb3StorageDefination,
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
                          style: context.textTheme.titleMedium),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                          child: AddressDetailsView(
                              address: widget.account.address)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: WidgetConstant.paddingVertical20,
                            child: FixedElevatedButton.icon(
                                label: Text("remove_account".tr),
                                onPressed: () {
                                  context
                                      .openSliverDialog<bool>(
                                        (p0) => DialogTextView(
                                            buttonWidget:
                                                DialogDoubleButtonView(
                                              firstButtonLabel: "remove".tr,
                                              secoundButtonLabel: "cancel".tr,
                                            ),
                                            widget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("remove_account_desc".tr),
                                              ],
                                            )),
                                        "remove_account".tr,
                                      )
                                      .then(deleteAccount);
                                },
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
