import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum WalletAccsessType {
  privateKey,
  seed,
  verify,
  extendedKey;

  bool get isAccsessKey =>
      this == WalletAccsessType.privateKey ||
      this == WalletAccsessType.extendedKey;
  bool get isExtendedKey => this == WalletAccsessType.extendedKey;
}

typedef FuncWidgetStringPaagePrgoressKey = Widget Function(
    List<AccessKeyResponse>, String);

class PasswordCheckerView extends StatefulWidget {
  const PasswordCheckerView(
      {required this.accsess,
      super.key,
      required this.onAccsess,
      required this.title,
      required this.subtitle,
      this.account,
      this.password,
      this.customKey});
  final FuncWidgetStringPaagePrgoressKey onAccsess;
  final WalletAccsessType accsess;
  final String title;
  final Widget subtitle;
  final CryptoAccountAddress? account;
  final String? password;
  final EncryptedCustomKey? customKey;

  @override
  State<PasswordCheckerView> createState() => _PasswordCheckerViewState();
}

class _PasswordCheckerViewState extends State<PasswordCheckerView>
    with SafeState {
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<StreamWidgetState> progressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "ExportSeedView");
  final GlobalKey<AppTextFieldState> textFildState =
      GlobalKey<AppTextFieldState>(debugLabel: "AppTextFieldState");
  String _password = "";

  List<AccessKeyResponse>? credentials;
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
    await getKey();
  }

  Future<void> getKey() async {
    progressKey.process();
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final result = await wallet.accsess(widget.accsess, _password,
        account: widget.account, accountId: widget.customKey?.id);
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

  bool inited = false;
  void _init() {
    if (inited) return;
    inited = true;
    _password = widget.password ?? "";
    if (_password.isNotEmpty) {
      getKey();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _init();
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
                child: Center(
                  child: CustomScrollView(
                    shrinkWrap: true,
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
                                            key: textFildState,
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
                                                initialStatus:
                                                    widget.password != null
                                                        ? StreamWidgetStatus
                                                            .progress
                                                        : StreamWidgetStatus
                                                            .idle,
                                                buttomWidget:
                                                    FixedElevatedButton(
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
      ),
    );
  }
}
