import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';

import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

class EraseWalletView extends StatelessWidget {
  const EraseWalletView({super.key});
  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
        accsess: WalletAccsessType.seed,
        onAccsess: (p0, p1) {
          return _EraseWalletView(password: p1);
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

  void onDelete() async {
    progressKey.progressText("deleting_wallet".tr);
    final model = context.watch<WalletProvider>(StateIdsConst.main);
    final result = await model.eraseWallet(widget.password);
    if (result.hasError) {
      progressKey.errorText(result.error!.tr);
    } else {
      progressKey.successText("wallet_deleted_success".tr, backToIdle: false);
      await MethodCaller.wait();
      navigatorKey?.currentContext?.popToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageProgress(
      key: progressKey,
      backToIdle: AppGlobalConst.oneSecoundDuration,
      child: () => UnfocusableChild(
        child: ConstraintsBoxView(
          padding: WidgetConstant.paddingHorizontal20,
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
                    onPressed: onDelete,
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
