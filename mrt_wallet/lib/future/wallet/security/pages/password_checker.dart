import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/wroker/keys/keys.dart';

enum WalletAccsessType {
  privateKey,
  seed,
  verify,
  unlock,
  extendedKey;

  bool get isAccsessKey =>
      this == WalletAccsessType.privateKey ||
      this == WalletAccsessType.extendedKey;
  bool get isAccessMnemonic => this == WalletAccsessType.seed;
  bool get isExtendedKey => this == WalletAccsessType.extendedKey;
  bool get isUnlock => this == WalletAccsessType.unlock;
}

typedef FuncWidgetStringPaagePrgoressKey = Widget Function(
    List<CryptoKeyData> credential, String password, WalletNetwork network);

class PasswordCheckerView extends StatefulWidget {
  const PasswordCheckerView(
      {required this.accsess,
      super.key,
      required this.onAccsess,
      required this.title,
      required this.subtitle,
      this.account,
      this.password,
      this.customKey,
      this.controller});
  final FuncWidgetStringPaagePrgoressKey onAccsess;
  final WalletAccsessType accsess;
  final String title;
  final Widget subtitle;
  final CryptoAddress? account;
  final String? password;
  final EncryptedCustomKey? customKey;
  final ScrollController? controller;

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
  late WalletProvider wallet;

  List<CryptoKeyData>? credentials;
  String? error;
  String? psaswordForm(String? v) {
    if (StrUtils.isStrongPassword(v)) return null;
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

  // void checkUnlockAccess() {
  //   if (widget.accsess == WalletAccsessType.unlock) {
  //     if (wallet.walletIsUnlock) {
  //       credentials = [FakeKeyData()];
  //       updateState();
  //     }
  //   }
  // }

  Future<void> getKey({bool isInit = false}) async {
    progressKey.process();

    final result = await wallet.accsess(widget.accsess, _password,
        account: widget.account, accountId: widget.customKey?.id);
    if (result.hasError) {
      if (isInit) {
        progressKey.idle();
      } else {
        error = result.error?.tr;
        progressKey.error();
      }
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
    if (_password.isNotEmpty || widget.accsess.isUnlock) {
      MethodUtils.after(() => getKey(isInit: true));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wallet = context.watch<WalletProvider>(StateConst.main);

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: UnfocusableChild(
        child: APPAnimatedSwitcher(
          duration: APPConst.animationDuraion,
          enable: credentials != null,
          widgets: {
            true: (c) =>
                widget.onAccsess(credentials!, _password, wallet.network),
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
                    state.widget.subtitle,
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
                                  Icon(
                                    Icons.security,
                                    size: APPConst.double80,
                                    color: ColorConst.green,
                                  ),
                                ],
                              ),
                              WidgetConstant.height8,
                              AppTextField(
                                  label: "wallet_password".tr,
                                  obscureText: true,
                                  key: state.textFildState,
                                  validator: state.psaswordForm,
                                  initialValue: state._password,
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
