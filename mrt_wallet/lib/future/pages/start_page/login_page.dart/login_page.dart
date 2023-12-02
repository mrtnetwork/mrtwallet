import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

class WalletLoginPageView extends StatefulWidget {
  const WalletLoginPageView({super.key});

  @override
  State<WalletLoginPageView> createState() => _WalletLoginPageViewState();
}

class _WalletLoginPageViewState extends State<WalletLoginPageView>
    with SafeState {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: "WalletLoginPageView");
  final GlobalKey<StreamWidgetState> buttonKey =
      GlobalKey<StreamWidgetState>(debugLabel: "WalletLoginPageView_1");
  String? _error;
  String password = "";
  void onChange(String v) {
    password = v;
    resetError();
  }

  void resetError() {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  void unlock() async {
    final provider = context.watch<WalletProvider>(StateIdsConst.main);
    if (!(formKey.currentState?.validate() ?? false)) return;
    buttonKey.process();
    final login = await provider.login(password);
    buttonKey.fromMethodResult(login);
    _error = login.error?.tr;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      padding: WidgetConstant.padding20,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            PageTitleSubtitle(title: null, body: Text("wallet_login_desc".tr)),
            const CircleAssetsImgaeView(AppGlobalConst.logo),
            WidgetConstant.height20,
            AppTextField(
              obscureText: true,
              onChanged: onChange,
              label: "password".tr,
              disableContextMenu: true,
              error: _error,
              validator: (v) {
                if (AppStringUtility.isStrongPassword(v)) {
                  return null;
                }
                return "password_desc".tr;
              },
            ),
            StreamWidget(
              padding: WidgetConstant.paddingVertical20,
              buttomWidget: FixedElevatedButton(
                onPressed: unlock,
                child: Text("unlock".tr),
              ),
              backToIdle: AppGlobalConst.oneSecoundDuration,
              key: buttonKey,
            ),
          ],
        ),
      ),
    );
  }
}
