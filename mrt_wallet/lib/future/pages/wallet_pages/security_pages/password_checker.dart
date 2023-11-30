import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum WalletAccsessType { privateKey, seed, verify }

typedef FuncWidgetStringPaagePrgoressKey = Widget Function(String, String);

class PasswordCheckerView extends StatefulWidget {
  const PasswordCheckerView(
      {required this.accsess,
      super.key,
      required this.onAccsess,
      required this.title,
      required this.subtitle,
      this.account});
  final FuncWidgetStringPaagePrgoressKey onAccsess;
  final WalletAccsessType accsess;
  final String title;
  final Widget subtitle;
  final CryptoAddress? account;

  @override
  State<PasswordCheckerView> createState() => _PasswordCheckerViewState();
}

class _PasswordCheckerViewState extends State<PasswordCheckerView>
    with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<StreamWidgetState> progressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "ExportSeedView");
  String _password = "";

  String? credentials;
  String? error;
  String? psaswordValidator(String? v) {
    if (AppStringUtility.isStrongPassword(v)) return null;
    return "password_desc".tr;
  }

  void onChange(String v) {
    _password = v;
    if (error != null) {
      error = null;
      setState(() {});
    }
  }

  void onSubmit() async {
    if (!(form.currentState?.validate() ?? false)) return;
    if (error != null) {
      error = null;
      setState(() {});
    }
    progressKey.process();
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final result = await wallet.accsess(widget.accsess, _password,
        account: widget.account);
    if (result.hasError) {
      error = result.error?.tr;
      progressKey.error();
    } else {
      credentials = result.result;
      progressKey.success();
    }
    setState(() {});
  }

  void onChangeShowMnemonic() {
    setState(() {});
  }

  double? _heightSpace;

  void onChangeHeight(Size size) {
    if (_heightSpace != null) return;
    double mid = (size.height / 2) - 88;
    if (mid.isNegative) {
      mid = 0;
    }
    _heightSpace = mid;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedSwitcher(
        duration: AppGlobalConst.animationDuraion,
        child: credentials != null
            ? widget.onAccsess(credentials!, _password)
            : UnfocusableChild(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                        padding: WidgetConstant.padding20,
                        child: AnimatedSwitcher(
                          duration: AppGlobalConst.animationDuraion,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.subtitle,
                              Form(
                                key: form,
                                child: AnimatedSwitcher(
                                  duration: AppGlobalConst.animationDuraion,
                                  child: MeasureSize(
                                    onChange: onChangeHeight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: _heightSpace),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.security,
                                              size: AppGlobalConst.double80,
                                              color: CustomColors.green,
                                            ),
                                          ],
                                        ),
                                        WidgetConstant.height8,
                                        AppTextField(
                                          label: "wallet_password".tr,
                                          obscureText: true,
                                          validator: psaswordValidator,
                                          initialValue: _password,
                                          onChanged: onChange,
                                          error: error,
                                          helperText:
                                              "enter_wallet_password_to_continue"
                                                  .tr,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            StreamWidget(
                                              key: progressKey,
                                              buttomWidget: FixedElevatedButton(
                                                onPressed: onSubmit,
                                                child: Text("unlock".tr),
                                              ),
                                              backToIdle: AppGlobalConst
                                                  .milliseconds100,
                                              padding: WidgetConstant
                                                  .paddingVertical20,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
