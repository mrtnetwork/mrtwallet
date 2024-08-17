import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/security/pages/password_checker.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/models.dart';

class EraseWalletView extends StatelessWidget {
  const EraseWalletView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.verify,
        onAccsess: (crendential, password, network) {
          return _EraseWalletView(password: password);
        },
        title: "delete_wallet".tr,
        subtitle: PageTitleSubtitle(
            title: "delete_wallet_confirmation".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("delete_wallet_desc".tr),
                WidgetConstant.height8,
                Text("enter_wallet_password_to_continue".tr),
              ],
            )));
  }
}

class _EraseWalletView extends StatefulWidget {
  const _EraseWalletView({required this.password});

  final String password;

  @override
  State<_EraseWalletView> createState() => _EraseWalletViewState();
}

class _EraseWalletViewState extends State<_EraseWalletView> with SafeState {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();

  void onDelete(bool? accept) async {
    if (accept != true) return;
    progressKey.progressText("deleting_wallet".tr);
    final model = context.watch<WalletProvider>(StateConst.main);
    final result = await model.wallet.eraseWallet(widget.password);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("wallet_deleted_success".tr, backToIdle: false);
      await MethodUtils.wait();
      navigatorKey?.currentContext?.popToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: APPConst.oneSecoundDuration,
      child: (c) => UnfocusableChild(
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              WidgetConstant.height20,
              PageTitleSubtitle(
                  title: "delete_wallet_confirmation".tr,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("delete_wallet_desc".tr),
                    ],
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FixedElevatedButton(
                    onPressed: () {
                      context
                          .openSliverDialog<bool>(
                              (p0) => DialogTextView(
                                    text: "wallet_deletation_desc".tr,
                                    buttonWidget:
                                        const DialogDoubleButtonView(),
                                  ),
                              "erase_wallet".tr)
                          .then(onDelete);
                    },
                    child: Text("delete_wallet".tr),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
