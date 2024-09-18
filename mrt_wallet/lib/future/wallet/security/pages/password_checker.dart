import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/constant/constant.dart';

typedef FuncWidgetStringPaagePrgoressKey = Widget Function(
    List<CryptoKeyData> credential, String password, WalletNetwork network);

class PasswordCheckerView extends StatefulWidget {
  const PasswordCheckerView(
      {required this.accsess,
      super.key,
      required this.onAccsess,
      this.title,
      this.subtitle,
      this.account,
      this.password,
      this.customKey,
      this.controller,
      this.appbar});
  final FuncWidgetStringPaagePrgoressKey onAccsess;
  final WalletAccsessType accsess;
  final String? title;
  final Widget? subtitle;
  final ChainAccount? account;
  final String? password;
  final EncryptedCustomKey? customKey;
  final ScrollController? controller;
  final AppBar? appbar;

  @override
  State<PasswordCheckerView> createState() => _PasswordCheckerViewState();
}

class _PasswordCheckerViewState extends State<PasswordCheckerView>
    with SafeState {
  late final WalletAccsessType access = widget.accsess;
  String _entredPassword = "";
  String _correctPassword = "";

  void _onPause() {
    credentials = null;
    _entredPassword = "";
    _correctPassword = "";
    updateState();
  }

  AppLifecycleListener? _lifeCycle;

  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<StreamWidgetState> progressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "ExportSeedView");
  final GlobalKey<AppTextFieldState> textFildState =
      GlobalKey<AppTextFieldState>(debugLabel: "AppTextFieldState");
  // String _password = "";
  late WalletProvider wallet;

  List<CryptoKeyData>? credentials;
  String? error;
  String? psaswordForm(String? v) {
    if (StrUtils.isStrongPassword(v)) return null;
    return "password_validator".tr;
  }

  void onChange(String v) {
    _entredPassword = v;
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

  Future<void> getKey({String? password}) async {
    password ??= textFildState.currentState?.getValue();
    if (password == null || password.isEmpty) return;
    progressKey.process();

    final result = await wallet.wallet.accsess(widget.accsess, password,
        account: widget.account, accountId: widget.customKey?.id);
    if (result.hasError) {
      error = result.error?.tr;
      progressKey.error();
    } else {
      credentials = result.result;
      _correctPassword = password;
      progressKey.success();
    }
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

  void listener(WalletEventStaus status) {
    if (status != WalletEventStaus.unlock) {
      credentials = null;
      _entredPassword = "";
      _correctPassword = "";
    } else {
      if (access.isUnlock) {
        credentials = [FakeKeyData()];
      }
    }
    updateState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wallet = context.watch<WalletProvider>(StateConst.main);
    wallet.wallet.addWalletStatusListener(listener);
    MethodUtils.after(() => getKey(password: widget.password));
  }

  @override
  void initState() {
    if (!widget.accsess.isUnlock) {
      _lifeCycle = AppLifecycleListener(onHide: _onPause);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    wallet.wallet.removeWalletStatusListener(listener);
    _lifeCycle?.dispose();
  }

  PreferredSizeWidget? appBar() {
    if (widget.appbar == null && widget.title == null) return null;
    return widget.appbar ?? AppBar(title: Text(widget.title ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: UnfocusableChild(
        child: APPAnimatedSwitcher(
          duration: APPConst.animationDuraion,
          enable: credentials != null,
          widgets: {
            true: (c) => widget.onAccsess(
                credentials!, _correctPassword, wallet.wallet.network),
            false: (c) => _PasswordWriterView(this)
          },
        ),
      ),
    );
  }
}

class _PasswordWriterView extends StatelessWidget {
  const _PasswordWriterView(this.state, {Key? key}) : super(key: key);
  final _PasswordCheckerViewState state;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomScrollView(
        shrinkWrap: true,
        controller: state.widget.controller,
        slivers: [
          SliverToBoxAdapter(
            child: ConstraintsBoxView(
              padding: WidgetConstant.padding20,
              child: AnimatedSwitcher(
                duration: APPConst.animationDuraion,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    state.widget.subtitle ??
                        PageTitleSubtitle(
                            title: "wallet_password".tr,
                            body: Text("enter_wallet_password_request".tr)),
                    Form(
                      key: state.form,
                      child: AnimatedSwitcher(
                        duration: APPConst.animationDuraion,
                        child: MeasureSize(
                          onChange: state.onChangeHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: state._heightSpace),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security,
                                      size: APPConst.double80,
                                      color: ColorConst.green),
                                ],
                              ),
                              WidgetConstant.height8,
                              AppTextField(
                                  label: "wallet_password".tr,
                                  obscureText: true,
                                  key: state.textFildState,
                                  validator: state.psaswordForm,
                                  initialValue: state._entredPassword,
                                  onChanged: state.onChange,
                                  error: state.error,
                                  helperText:
                                      "enter_wallet_password_to_continue".tr),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamWidget(
                                    key: state.progressKey,
                                    initialStatus: state.widget.password != null
                                        ? StreamWidgetStatus.progress
                                        : StreamWidgetStatus.idle,
                                    buttonWidget: FixedElevatedButton(
                                      onPressed: state.onSubmit,
                                      child: Text("unlock".tr),
                                    ),
                                    backToIdle: APPConst.milliseconds100,
                                    padding: WidgetConstant.paddingVertical20,
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
    );
  }
}
