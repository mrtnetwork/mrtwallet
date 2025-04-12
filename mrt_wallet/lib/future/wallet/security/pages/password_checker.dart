import 'dart:async';

import 'package:flutter/foundation.dart';
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
typedef ONWALLETACCESSS = FutureOr<Object?> Function(String password);

class PasswordCheckerView extends StatefulWidget {
  const PasswordCheckerView(
      {required this.accsess,
      this.onWalletAccess,
      super.key,
      this.onAccsess,
      this.title,
      this.subtitle,
      this.account,
      this.password,
      this.importedKey,
      this.controller,
      this.backgroundColor,
      this.appbar});
  final FuncWidgetStringPaagePrgoressKey? onAccsess;
  final WalletAccsessType accsess;
  final String? title;
  final Widget? subtitle;
  final ChainAccount? account;
  final String? password;
  final EncryptedCustomKey? importedKey;
  final ScrollController? controller;
  final AppBar? appbar;
  final ONWALLETACCESSS? onWalletAccess;
  final Color? backgroundColor;

  @override
  State<PasswordCheckerView> createState() => _PasswordCheckerViewState();
}

class _PasswordCheckerViewState extends State<PasswordCheckerView>
    with SafeState {
  late final WalletAccsessType access = widget.accsess;
  StreamSubscription<dynamic>? _walletStatus;
  Live<int?> lockTime = Live(null);
  String _entredPassword = "";
  String _correctPassword = "";
  AppLifecycleListener? _lifeCycle;
  final GlobalKey<FormState> form =
      GlobalKey<FormState>(debugLabel: "ExportSeedView");
  final GlobalKey<StreamWidgetState> progressKey =
      GlobalKey<StreamWidgetState>(debugLabel: "ExportSeedView");
  final GlobalKey<AppTextFieldState> textFildState =
      GlobalKey<AppTextFieldState>(debugLabel: "AppTextFieldState");
  late WalletProvider wallet;
  List<CryptoKeyData>? credentials;
  String? error;
  static const int reminingWalletTimeAlert = kDebugMode ? 50 : 15;
  final GlobalKey<ScaffoldMessengerState> scaffolKey = GlobalKey();

  ScaffoldFeatureController<MaterialBanner, MaterialBannerClosedReason>?
      controller;
  void onUpdateWalletTimer(dynamic _) {
    final time = wallet.wallet.reminingWalletTime;

    if (time == null || time > reminingWalletTimeAlert) {
      controller?.close();
      controller = null;
      lockTime.dispose();
      lockTime.value = time;
    } else {
      lockTime.value = time;
      controller ??= scaffolKey.currentState?.showMaterialBanner(MaterialBanner(
          actions: [
            ElevatedButton(
                onPressed: () {
                  wallet.wallet.accsess(WalletAccsessType.unlock, '');
                },
                child: Text("keep_unlock".tr))
          ],
          content: LiveWidget(() {
            return Text("wallet_lock_timer_desc"
                .tr
                .replaceOne(lockTime.value.toString()));
          })));
    }
    // scaffolKey.
  }

  void _onPause() {
    credentials = null;
    _entredPassword = "";
    _correctPassword = "";
    updateState();
  }

  String? psaswordForm(String? v) {
    if (StrUtils.isStrongPassword(v)) return null;
    return "password_validator".tr;
  }

  void onChange(String v) {
    _entredPassword = v;
    if (error != null) {
      error = null;
      updateState();
    }
  }

  void onSubmit() async {
    if (!(form.currentState?.validate() ?? false)) return;
    if (error != null) {
      error = null;
      updateState();
    }
    await getKey();
  }

  Future<void> getKey({String? password}) async {
    password ??= textFildState.currentState?.getValue();
    if (password == null || password.isEmpty) return;
    progressKey.process();

    try {
      final result = await wallet.wallet.accsess(widget.accsess, password,
          account: widget.account, keyId: widget.importedKey?.id);
      if (result.hasError) {
        error = result.error?.tr;
        progressKey.error();
      } else {
        if (widget.onWalletAccess != null) {
          final r = await MethodUtils.call(() async {
            return widget.onWalletAccess!.call(password!);
          });
          if (r.hasError) {
            error = result.error?.tr;
            progressKey.error();
            return;
          }
          context.pop(r.result);
        }
        credentials = result.result;
        _correctPassword = password;
        progressKey.success();
      }
    } finally {
      updateState();
    }
  }

  double? _heightSpace;

  void onChangeHeight(Size size) {
    if (_heightSpace != null) return;
    double mid = (size.height / 2) - 88;
    if (mid.isNegative) {
      mid = 0;
    }
    _heightSpace = mid;
    updateState();
  }

  void listener(WalletEventStaus status) {
    if (status != WalletEventStaus.unlock) {
      credentials = null;
      _entredPassword = "";
      _correctPassword = "";
      context.backToCurrent();
    } else {
      if (access.isUnlock && widget.onWalletAccess == null) {
        credentials = [FakeKeyData()];
      }
    }

    updateState();
  }

  @override
  void initState() {
    if (!widget.accsess.isUnlock) {
      _lifeCycle = AppLifecycleListener(onHide: _onPause);
    }
    super.initState();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    wallet = context.watch<WalletProvider>(StateConst.main);
    wallet.wallet.addWalletStatusListener(listener);
    MethodUtils.after(() => getKey(password: widget.password));
    _walletStatus =
        Stream.periodic(const Duration(seconds: 1)).listen(onUpdateWalletTimer);
  }

  @override
  void dispose() {
    super.dispose();
    _walletStatus?.cancel();
    _walletStatus = null;
    wallet.wallet.removeWalletStatusListener(listener);
    _lifeCycle?.dispose();
    lockTime.dispose();
    controller = null;
  }

  PreferredSizeWidget? appBar() {
    if (widget.appbar == null && widget.title == null) return null;
    return widget.appbar ?? AppBar(title: Text(widget.title ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffolKey,
      child: Scaffold(
        backgroundColor: credentials == null ? null : widget.backgroundColor,
        appBar: appBar(),
        body: UnfocusableChild(
          child: APPAnimatedSwitcher(
            duration: APPConst.animationDuraion,
            enable: credentials != null,
            widgets: {
              true: (c) => widget.onAccsess
                  ?.call(credentials!, _correctPassword, wallet.wallet.network),
              false: (c) => _PasswordWriterView(this)
            },
          ),
        ),
      ),
    );
  }
}

class _PasswordWriterView extends StatelessWidget {
  const _PasswordWriterView(this.state);
  final _PasswordCheckerViewState state;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomScrollView(
        shrinkWrap: true,
        controller: state.widget.controller,
        slivers: [
          SliverConstraintsBoxView(
            padding: WidgetConstant.paddingHorizontal20,
            sliver: SliverToBoxAdapter(
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
                                ButtonProgress(
                                  key: state.progressKey,
                                  initialStatus: state.widget.password != null
                                      ? StreamWidgetStatus.progress
                                      : StreamWidgetStatus.idle,
                                  child: (context) => FixedElevatedButton(
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
          )
        ],
      ),
    );
  }
}
